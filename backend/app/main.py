from fastapi import FastAPI, HTTPException, Query
from typing import List, Optional

from app.firestore import get_db
from app.model import TaskOut, ToolOut, RecommendToolsRequest, RecommendedToolOut, PopularTools
from app.ai_service import rank_tools_with_gemini


# Create the FastAPI app.
#
# This is the main backend application object.
# FastAPI uses this object to register routes such as:
#
# GET /health
# GET /quick-actions
# POST /tools/recommend
app = FastAPI(title="Tool4All API")


# ---------------------------------------------------------------------
# Health Check Route
# ---------------------------------------------------------------------

@app.get("/health")
def health():
    """
    Simple test route to check if the backend server is running.

    Example response:
    {
        "status": "Ok"
    }

    You can test this in the browser:
    http://127.0.0.1:8000/health
    """
    return {"status": "Ok"}

# ---------------------------------------------------------------------
# Task Routes
# ---------------------------------------------------------------------

@app.get("/tasks", response_model=List[TaskOut])
def list_tasks(enabled: bool = True):
    """
    Gets tasks from the Firestore 'tasks' collection.

    A task represents a category or use case in your app.

    Example tasks:
    - Writing
    - Coding
    - Image generation
    - Productivity

    Parameters:
    - enabled:
        If True, only return tasks where enabled == True.
        This allows you to hide tasks without deleting them from Firestore.

    Returns:
    - A list of TaskOut objects.
    """

    # Connect to Firestore.
    db = get_db()

    # Start a query on the "tasks" collection.
    q = db.collection("tasks")

    # If enabled is True, only get active/enabled tasks.
    if enabled:
        q = q.where("enabled", "==", True)

    tasks: List[TaskOut] = []

    # Loop through every matching task document in Firestore.
    for doc in q.stream():
        data = doc.to_dict() or {}

        # Convert the Firestore document into a TaskOut Pydantic model.
        tasks.append(
            TaskOut(
                id=doc.id,
                label=data.get("label", doc.id),
                description=data.get("description"),
                enabled=data.get("enabled", True),
                iconKey=data.get("iconKey", "help"),
                popularityHint=data.get("popularityHint"),
                keywords=data.get("keywords", []),
            )
        )

    # Sort tasks by popularityHint from highest to lowest.
    #
    # If popularityHint is missing, use 0.
    tasks.sort(key=lambda t: (t.popularityHint or 0), reverse=True)

    return tasks


@app.get("/quick-actions", response_model=List[TaskOut])
def quick_actions():
    """
    Gets the top 4 tasks to display as Quick Action cards.

    This route is used by the Flutter search page when the app first opens.

    Frontend usage:
    - search_page.dart calls ApiClient.getQuickActions()
    - ApiClient calls GET /quick-actions
    - The returned tasks become Quick Action cards

    Returns:
    - The first 4 enabled tasks sorted by popularityHint.
    """

    # Reuse the list_tasks function instead of duplicating Firestore logic.
    tasks = list_tasks(enabled=True)

    # Return only the top 4 tasks for the home/search page.
    return tasks[:4]

# ---------------------------------------------------------------------
# Popular Tool Routes
# ---------------------------------------------------------------------
@app.get("/popularTools", response_model=List[ToolOut])
def get_popular_tools(
    limit: int = Query(default=5, ge=1, le=8),
    min_popularity: int = Query(default=70, ge=0, le=100),
):
    """
    Returns popular tools for the home page.

    A tool is returned only if:
    - isActive is True
    - isPopular is True
    - popularityHint is at least min_popularity

    The tools are sorted from highest popularityHint to lowest.
    """

    # Connect to Firestore.
    db = get_db()

    # Get tools that are active and marked as popular.
    q = (
        db.collection("tools")
        .where("isActive", "==", True)
        .where("isPopular", "==", True)
    )

    # This list will store the popular tools we want to return.
    popularTools: List[ToolOut] = []

    # Loop through each matching Firestore document.
    for doc in q.stream():
        data = doc.to_dict() or {}

        # Get the tool's popularity score.
        # If the field does not exist, use 0.
        popularity_hint = data.get("popularityHint", 0)

        # Skip tools that are below the minimum popularity requirement.
        if popularity_hint < min_popularity:
            continue

        # Convert the Firestore document into a ToolOut object.
        popularTools.append(
            ToolOut(
                toolId=doc.id,
                name=data.get("name", doc.id),
                shortDescription=data.get("shortDescription"),
                websiteUrl=data.get("websiteUrl"),
                pricingModel=data.get("pricingModel"),
                platforms=data.get("platforms", []),
                taskIds=data.get("taskIds", []),
                isActive=data.get("isActive", True),
                iconKey=data.get("iconKey", "smart_toy"),
                isPopular=data.get("isPopular", False),
                popularityHint=popularity_hint,
            )
        )

    # Sort tools so the most popular ones appear first.
    popularTools.sort(key=lambda tool: tool.popularityHint, reverse=True)

    # Return only the requested number of tools.
    return popularTools[:limit]


# ---------------------------------------------------------------------
# Tool Routes
# ---------------------------------------------------------------------

@app.get("/tasks/{task_id}/tools", response_model=List[ToolOut])
def tools_for_task(
    task_id: str,
    platform: Optional[str] = Query(default=None),
    budget: Optional[str] = Query(default=None),
    limit: int = Query(default=20, ge=1, le=50),
):
    """
    Gets tools that belong to a specific task.

    This route is used when the user taps a Quick Action card.

    Example:
    If the user taps "Writing", the frontend may call:

    GET /tasks/writing/tools

    Parameters:
    - task_id:
        The selected task ID.
        This should match one of the values inside a tool's taskIds list.

    - platform:
        Optional platform filter.
        Example: web, ios, android

    - budget:
        Optional pricing filter.
        Example: free, paid, freemium

    - limit:
        Maximum number of tools to return.
        Must be between 1 and 50.

    Returns:
    - A list of ToolOut objects.
    """

    db = get_db()

    # Query active tools that contain the selected task_id in their taskIds list.
    q = (
        db.collection("tools")
        .where("isActive", "==", True)
        .where("taskIds", "array_contains", task_id)
    )

    tools: List[ToolOut] = []

    for doc in q.stream():
        data = doc.to_dict() or {}

        # Convert the Firestore document into a ToolOut object.
        tool = ToolOut(
            toolId=doc.id,
            name=data.get("name", doc.id),
            shortDescription=data.get("shortDescription"),
            websiteUrl=data.get("websiteUrl"),
            pricingModel=data.get("pricingModel"),
            platforms=data.get("platforms", []),
            taskIds=data.get("taskIds", []),
            isActive=data.get("isActive", True),
            popularityHint = data.get("popularityHint", 0)
        )

        # If the frontend requested a platform filter, skip tools
        # that do not support that platform.
        if platform and platform not in tool.platforms:
            continue

        # If the frontend requested a budget filter, skip tools
        # that do not match that pricing model.
        if budget and tool.pricingModel != budget:
            continue

        tools.append(tool)

    return tools[:limit]


@app.get("/tools/{tool_id}", response_model=ToolOut)
def tool_detail(tool_id: str):
    """
    Gets full information for one specific tool.

    This route can be used later when the user taps a tool card
    and you want to show a tool detail page.

    Example:
    GET /tools/chatgpt

    Parameters:
    - tool_id:
        The Firestore document ID of the tool.

    Returns:
    - One ToolOut object.

    Raises:
    - 400 error if the tool does not exist.
    """

    db = get_db()

    # Look for one document inside the "tools" collection.
    doc = db.collection("tools").document(tool_id).get()

    # If Firestore does not find the document, return an error.
    if not doc.exists:
        raise HTTPException(status_code=400, detail="Tool not found")

    data = doc.to_dict() or {}

    return ToolOut(
        toolId=doc.id,
        name=data.get("name", doc.id),
        shortDescription=data.get("shortDescription"),
        websiteUrl=data.get("websiteUrl"),
        pricingModel=data.get("pricingModel"),
        platforms=data.get("platforms", []),
        taskIds=data.get("taskIds", []),
        isActive=data.get("isActive", True),
    )


# ---------------------------------------------------------------------
# AI Recommendation Route
# ---------------------------------------------------------------------

@app.post("/tools/recommend", response_model=List[RecommendedToolOut])
def recommend_tools(request: RecommendToolsRequest):
    """
    Recommends tools based on the user's search query.

    This route is used by the Flutter search bar.

    Frontend flow:
    1. User types a search query.
    2. search_page.dart calls ApiClient.recommendTools().
    3. ApiClient sends POST /tools/recommend.
    4. Backend loads active tools from Firestore.
    5. Backend filters tools by platform and budget.
    6. Backend sends the filtered tools to Gemini.
    7. Gemini ranks the tools.
    8. Backend returns the ranked tools to Flutter.

    Request body example:
    {
        "query": "I need help writing a resume",
        "platforms": ["web"],
        "budget": "freemium",
        "limit": 5
    }

    Returns:
    - A list of recommended tools with score and reason.
    """

    # Force MVP result limit to 5.
    #
    # Better version:
    # Instead of changing request.limit directly, you can use:
    #
    # limit = min(request.limit, 5)
    #
    # That lets the frontend request less than 5 if needed.
    request.limit = 5

    db = get_db()

    # Start with all active tools.
    query = db.collection("tools").where("isActive", "==", True)

    tools: List[ToolOut] = []

    # Load tools from Firestore.
    for doc in query.stream():
        data = doc.to_dict() or {}

        tool = ToolOut(
            toolId=doc.id,
            name=data.get("name", doc.id),
            shortDescription=data.get("shortDescription"),
            websiteUrl=data.get("websiteUrl"),
            pricingModel=data.get("pricingModel"),
            platforms=data.get("platforms", []),
            taskIds=data.get("taskIds", []),
            isActive=data.get("isActive", True),
            popularityHint=data.get("popularityHint",0),
        )

        # If platforms were provided, keep only tools that match
        # at least one requested platform.
        #
        # Example:
        # request.platforms = ["web"]
        # tool.platforms = ["web", "ios"]
        # This tool is kept.
        if request.platforms:
            if not any(platform in tool.platforms for platform in request.platforms):
                continue

        # If budget was provided, keep only tools with matching pricingModel.
        if request.budget and tool.pricingModel != request.budget:
            continue

        tools.append(tool)

    # If no tools matched the filters, return an empty list.
    if not tools:
        return []

    # Ask Gemini to rank the filtered tools.
    ranked = rank_tools_with_gemini(
        user_query=request.query,
        tools=tools,
        limit=request.limit,
    )

    # Create a dictionary where:
    #
    # key = toolId
    # value = full ToolOut object
    #
    # This makes it easy to find the full tool data after Gemini
    # returns only the ranked toolId.
    tools_by_id = {tool.toolId: tool for tool in tools}

    results: List[RecommendedToolOut] = []

    # Convert Gemini ranking results into API response objects.
    for rec in ranked.recommendations:
        tool = tools_by_id.get(rec.toolId)

        # If Gemini returns a toolId that does not exist in our tools list,
        # skip it instead of crashing.
        if tool is None:
            continue

        # Combine:
        # - original tool data from Firestore
        # - score from Gemini
        # - reason from Gemini
        results.append(
            RecommendedToolOut(
                **tool.model_dump(),
                score=rec.score,
                reason=rec.reason,
            )
        )

    return results[:request.limit]


# ---------------------------------------------------------------------
# Debug Route
# ---------------------------------------------------------------------

@app.get("/debug/tools")
def debug_tools():
    """
    Debug route that returns raw tools from Firestore.

    This is useful while developing because it lets you check
    what data actually exists in your Firestore database.

    Example:
    GET /debug/tools

    Returns:
    [
        {
            "id": "chatgpt",
            "data": {
                "name": "ChatGPT",
                "platforms": ["web"],
                ...
            }
        }
    ]

    Important:
    This route is useful for development, but you may want to remove
    or protect it before deploying the app publicly.
    """

    db = get_db()

    docs = db.collection("tools").stream()

    result = []

    for doc in docs:
        result.append(
            {
                "id": doc.id,
                "data": doc.to_dict(),
            }
        )

    return result
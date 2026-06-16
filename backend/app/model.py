from pydantic import BaseModel, Field
from typing import List, Optional


# ---------------------------------------------------------------------
# Task Models
# ---------------------------------------------------------------------

class TaskOut(BaseModel):
    """
    Represents one task/category in the app.

    A task is a user need or category, such as:
    - Writing
    - Coding
    - Image generation
    - Productivity

    This model is returned by routes like:
    - GET /tasks
    - GET /quick-actions
    """

    # The unique ID of the task.
    #
    # Usually this is the Firestore document ID.
    #
    # Example:
    # "writing"
    # "coding"
    id: str

    # The display name shown in the Flutter app.
    #
    # Example:
    # "Writing"
    # "Coding"
    label: str

    # Optional longer explanation of the task.
    #
    # Example:
    # "Tools that help users write essays, resumes, and emails."
    description: Optional[str] = None

    # The icon key sent to Flutter.
    #
    # Flutter converts this string into an actual icon using iconMap
    # inside search_page.dart.
    #
    # Example:
    # "edit_note"
    # "code"
    # "image"
    iconKey: str

    # Controls whether this task should be shown in the app.
    #
    # If enabled is False, the backend can hide it without deleting it
    # from Firestore.
    enabled: bool = True

    # Optional number used to sort tasks by popularity.
    #
    # Higher number = shown earlier.
    #
    # Example:
    # 100
    # 50
    # 10
    popularityHint: Optional[int] = None

    # Extra words related to this task.
    #
    # These can be useful later for search, filtering, or AI ranking.
    #
    # Example:
    # ["essay", "resume", "email", "writing"]
    keywords: List[str] = Field(default_factory=list)


# ---------------------------------------------------------------------
# Tool Models
# ---------------------------------------------------------------------

class ToolOut(BaseModel):
    """
    Represents one tool in the app.

    A tool is an app, website, or AI product that can help the user.

    Example tools:
    - ChatGPT
    - GitHub Copilot
    - Jasper AI
    - Canva

    This model is returned by routes like:
    - GET /tasks/{task_id}/tools
    - GET /tools/{tool_id}
    """

    # The unique ID of the tool.
    #
    # Usually this is the Firestore document ID.
    #
    # Example:
    # "chatgpt"
    # "github-copilot"
    toolId: str

    # The display name of the tool.
    #
    # Example:
    # "ChatGPT"
    # "GitHub Copilot"
    name: str

    # Short description shown in Flutter.
    #
    # Example:
    # "AI chatbot for writing, research, and brainstorming."
    shortDescription: Optional[str] = None

    # Optional website link for the tool.
    #
    # Example:
    # "https://chat.openai.com"
    websiteUrl: Optional[str] = None

    # Pricing type of the tool.
    #
    # Example:
    # "free"
    # "paid"
    # "freemium"
    pricingModel: Optional[str] = None

    # Platforms supported by the tool.
    #
    # Example:
    # ["web", "ios", "android"]
    platforms: List[str] = Field(default_factory=list)

    # The task IDs this tool belongs to.
    #
    # Example:
    # ["writing", "research", "productivity"]
    taskIds: List[str] = Field(default_factory=list)

    # Controls whether this tool should appear in the app.
    #
    # If isActive is False, the backend can hide the tool without deleting
    # it from Firestore.
    isActive: bool = True

    #Show if this tool is popular
    #
    #If it is not popular, it will hide it from popular tool search
    isPopular: bool = False

    #Quanity of how popular the tool is
    #
    popularityHint: int = 0

# ---------------------------------------------------------------------
# Recommendation Request Model
# ---------------------------------------------------------------------

class RecommendToolsRequest(BaseModel):
    """
    Represents the request body sent from Flutter to the backend
    when the user searches for tools.

    This model is used by:
    - POST /tools/recommend

    Example request body:
    {
        "query": "I need help writing a resume",
        "platforms": ["web"],
        "budget": "freemium",
        "limit": 5
    }
    """

    # The user's search text.
    #
    # Example:
    # "I need help making an application"
    # "I need help writing a resume"
    query: str

    # Optional platform filters.
    #
    # Flutter sends this as a list, so the backend must use List[str].
    #
    # Example:
    # ["web"]
    # ["ios", "android"]
    platforms: Optional[List[str]] = None

    # Optional budget/pricing filter.
    #
    # Example:
    # "free"
    # "paid"
    # "freemium"
    budget: Optional[str] = None

    # Maximum number of recommendations to return.
    #
    # Default is 5.
    limit: int = 5


# ---------------------------------------------------------------------
# Recommendation Response Model
# ---------------------------------------------------------------------

class RecommendedToolOut(ToolOut):
    """
    Represents one recommended tool returned to Flutter.

    This model includes all normal tool information from ToolOut,
    plus AI recommendation information:

    - score
    - reason

    This model is returned by:
    - POST /tools/recommend

    Example response item:
    {
        "toolId": "chatgpt",
        "name": "ChatGPT",
        "shortDescription": "AI chatbot for writing and research.",
        "websiteUrl": "https://chat.openai.com",
        "pricingModel": "freemium",
        "platforms": ["web", "ios", "android"],
        "taskIds": ["writing", "research"],
        "isActive": true,
        "score": 95,
        "reason": "Good for writing resumes and improving wording."
    }
    """

    # AI match score from 0 to 100.
    #
    # Higher score means Gemini thinks the tool is a better match
    # for the user's query.
    score: int

    # Short explanation for why this tool was recommended.
    #
    # Example:
    # "Good for writing resumes and improving wording."
    reason: str

class PopularTools(ToolOut):
    iconKey: str = "smart_toy"
    isPopular: bool = False
    popularityHint: int = 0
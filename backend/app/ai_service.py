import json
from typing import List

from google import genai
from google.genai import types
from pydantic import BaseModel, Field

from app.model import ToolOut


# ---------------------------------------------------------------------
# Gemini Client Setup
# ---------------------------------------------------------------------

# Creates a Gemini API client.
#
# The Gemini SDK will look for your API key from the environment variable:
#
# GEMINI_API_KEY
#
# Example in PowerShell:
# $env:GEMINI_API_KEY="your_api_key_here"
#
# Example in CMD:
# set GEMINI_API_KEY=your_api_key_here
client = genai.Client()


# ---------------------------------------------------------------------
# AI Ranking Models
# ---------------------------------------------------------------------

class ToolRank(BaseModel):
    """
    Represents one tool recommendation returned by Gemini.

    Gemini should return:
    - the tool ID
    - a match score
    - a short reason explaining why the tool is useful
    """

    toolId: str = Field(
        description="The exact toolId from the provided tool catalog."
    )

    score: int = Field(
        description="Match score from 0 to 100."
    )

    reason: str = Field(
        description="Short reason why this tool fits the user's task."
    )


class ToolRankResponse(BaseModel):
    """
    Represents the full structured response returned by Gemini.

    The response contains a list of recommended tools.
    """

    recommendations: List[ToolRank]


# ---------------------------------------------------------------------
# Gemini Tool Ranking Function
# ---------------------------------------------------------------------

def rank_tools_with_gemini(
    user_query: str,
    tools: List[ToolOut],
    limit: int = 5,
) -> ToolRankResponse:
    """
    Uses Gemini to rank tools based on the user's search query.

    This function is called by the FastAPI route:

    POST /tools/recommend

    Flow:
    1. Receive the user's search query.
    2. Receive a list of tools from Firestore.
    3. Convert the tools into a smaller catalog for Gemini.
    4. Ask Gemini to rank the tools.
    5. Force Gemini to return JSON that matches ToolRankResponse.
    6. Convert Gemini's JSON response back into a Pydantic object.

    Parameters:
    - user_query:
        The text the user typed into the search bar.

        Example:
        "I need help writing a resume"

    - tools:
        A list of ToolOut objects from Firestore.

        These are the tools Gemini is allowed to choose from.

    - limit:
        The maximum number of tools Gemini should recommend.

        Default is 5.

    Returns:
    - ToolRankResponse:
        A structured object containing ranked tool recommendations.
    """

    # Convert the full ToolOut objects into a smaller list of dictionaries.
    #
    # We only send Gemini the fields it needs for ranking.
    #
    # This is better than sending unnecessary data like websiteUrl or isActive.
    tool_catalog = [
        {
            "toolId": tool.toolId,
            "name": tool.name,
            "shortDescription": tool.shortDescription,
            "pricingModel": tool.pricingModel,
            "platforms": tool.platforms,
            "taskIds": tool.taskIds,
        }
        for tool in tools
    ]

    # Build the instruction prompt for Gemini.
    #
    # The prompt tells Gemini:
    # - what the user wants
    # - what tools are available
    # - what rules it must follow
    #
    # json.dumps(...) converts the Python tool_catalog list into readable JSON.
    # indent=2 makes the JSON easier for the model to understand.
    prompt = f"""
You are Tool4All's AI tool recommender.

User task:
{user_query}

Available tools:
{json.dumps(tool_catalog, indent=2)}

Rules:
1. Recommend only tools from the available tools list.
2. Do not invent new tools.
3. Use the exact toolId values from the available tools list.
4. Rank tools by how useful they are for the user's task.
5. Return at most {limit} tools.
6. Score each tool from 0 to 100.
7. Give a short, practical reason for each recommendation.
"""

    # Send the prompt to Gemini.
    #
    # model:
    #   The Gemini model used for ranking.
    #
    # contents:
    #   The prompt text.
    #
    # response_mime_type:
    #   Tells Gemini to return JSON instead of normal text.
    #
    # response_schema:
    #   Tells Gemini the exact structure we expect.
    #   In this case, the response should match ToolRankResponse.
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=ToolRankResponse,
        ),
    )

    # Gemini returns JSON text.
    #
    # model_validate_json converts that JSON string into a ToolRankResponse
    # Pydantic object.
    #
    # Example Gemini JSON:
    # {
    #   "recommendations": [
    #     {
    #       "toolId": "chatgpt",
    #       "score": 95,
    #       "reason": "Good for writing and brainstorming."
    #     }
    #   ]
    # }
    return ToolRankResponse.model_validate_json(response.text)
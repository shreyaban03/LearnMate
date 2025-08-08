from fastapi import FastAPI,HTTPException
from pydantic import BaseModel 
from dotenv import load_dotenv
from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from fastapi.middleware.cors import CORSMiddleware

import os

load_dotenv()

app=FastAPI()


app.add_middleware(

  CORSMiddleware,
  allow_origins=["*"],
  allow_methods=["*"],
  allow_headers=["*"],
)
groq_api_key = os.getenv("GROQ_API_KEY")
llm=ChatGroq(model="Gemma2-9b-It",groq_api_key=groq_api_key)



prompt = ChatPromptTemplate.from_messages([
("system",
"You are an expert AI tutor who has a deep understanding of all academic and university level subjects. "
"You are able to answer any questions related to these subjects with extreme depth and accuracy with a focus "
"on providing detailed explanations and insights to help the user understand the topic at hand. "
"Also provide the top 7 questions related to the topic along with detailed answers in an easy to understand language."),
("user", "Question: {question}")
])

parser = StrOutputParser()
chain = prompt | llm | parser

class Query(BaseModel):
  question: str

  @app.post("/chat")
  async def chat_response(query:Query):
    try:
      result = chain.invoke({"question": query.question})
      return {"response": result}
    except Exception as e:
      raise HTTPException(status_code=500,detail=str(e))


  @app.post("/video")
  async def video_handler(query:Query):
    try:
      response=chain.invoke({"question":query.question})
      # Placeholder for video generation logic
      
      return {"video_link": video_link}
    except Exception as e:
      raise HTTPException(status_code=500, detail=str(e))


  @app.post("/flashcards")
  async def generate_flashcards(query:Query):
    try:
      # Placeholder for flashcard generation logic
      result=chain.invoke({"question":user_input.question})
      flashcards = [] 
      for sentence in result.split('\n'):
        sentence = sentence.strip()
        if len(sentence) > 30 and len(flashcards) < 10:
          flashcards.append(sentence)

      return {"topic":user_input.question,"flashcards":flashcards}
    except Exception as e:
      raise HTTPException(status_code=500,detail=str(e))

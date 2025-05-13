# app/routers/coaching.py
from fastapi import APIRouter, HTTPException
from app.config import settings
from app.models.request import CoachingRequestDTO
from app.models.response import CoachingResponseDTO
from app.utils.text_utils import dict_to_text
from app.prompts.prompt import prompt_rag, prompt_json
from pinecone import Pinecone
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_pinecone import PineconeVectorStore
from langchain.chains import RetrievalQA, LLMChain
import os, json

router = APIRouter()

# API 키를 환경변수로 설정
os.environ["OPENAI_API_KEY"] = settings.OPENAI_API_KEY

# Pinecone 클라이언트 초기화
pc = Pinecone(api_key=settings.PINECONE_API_KEY, environment=settings.PINECONE_ENVIRONMENT)
index = pc.Index(settings.PINECIONE_INDEX_NAME)

# LangChain 임베딩 및 벡터스토어 초기화
embeddings = OpenAIEmbeddings(model="text-embedding-3-large")
vectorstore = PineconeVectorStore(index=index, embedding=embeddings, text_key="text")
retriever = vectorstore.as_retriever(search_kwargs={"k": settings.TOP_K})

# LLM 및 체인 초기화
llm = ChatOpenAI(temperature=0.7, max_tokens=1024, model_name=settings.MODEL_NAME)
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    return_source_documents=True,
    chain_type_kwargs={"prompt": prompt_rag}
)
json_chain = LLMChain(llm=llm, prompt=prompt_json)

@router.post("/", response_model=CoachingResponseDTO)
async def generate_coaching(request: CoachingRequestDTO):
    """
    주간 및 야간 데이터를 받아 수면 코칭 문구와 제안 리스트 반환
    """
    weekly_text = dict_to_text(request.weekly_data)
    night_text = dict_to_text(request.night_data)

    question = (
        f"주간 활동 데이터:\n{weekly_text}\n\n"
        f"야간 수면 데이터:\n{night_text}\n\n"
        "이처럼 기록된 사용자가 오늘 더 깊은 잠을 자려면?"
    )

    result = qa_chain.invoke({"query": question})
    coaching_text = result["result"]

    out = json_chain.invoke({"weekly_data": weekly_text, "coaching_text": coaching_text})

    try:
        suggestions = json.loads(out["text"])
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="JSON 파싱 오류: 제안 내용을 확인하세요.")

    return CoachingResponseDTO(coaching_text=coaching_text, activity_list=suggestions)

-- ==============================================================================
-- Supabase Schema & pgvector Setup for n8n AI Customer Support Agent
-- ==============================================================================

-- 1. Enable the pgvector extension to work with embedding vectors
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Create the documents table for Knowledge Base chunks
CREATE TABLE IF NOT EXISTS public.documents (
  id BIGSERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  embedding VECTOR(1536) -- 1536 dimensions for OpenAI text-embedding-3-small
);

-- 3. Create an HNSW index for high-performance cosine similarity searches
CREATE INDEX IF NOT EXISTS documents_embedding_hnsw_idx 
ON public.documents 
USING hnsw (embedding vector_cosine_ops);

-- 4. Create the similarity search function called by n8n LangChain Vector Store
CREATE OR REPLACE FUNCTION public.match_documents (
  query_embedding VECTOR(1536),
  match_count INT DEFAULT 5,
  filter JSONB DEFAULT '{}'::jsonb
) 
RETURNS TABLE (
  id BIGINT,
  content TEXT,
  metadata JSONB,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    documents.id,
    documents.content,
    documents.metadata,
    1 - (documents.embedding <=> query_embedding) AS similarity
  FROM public.documents
  WHERE documents.metadata @> filter
  ORDER BY documents.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- 5. (Optional) Audit table for tickets if migrating from n8n internal Data Tables to Supabase
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id BIGSERIAL PRIMARY KEY,
  session_id TEXT NOT NULL,
  customer_message TEXT NOT NULL,
  agent_answer TEXT NOT NULL,
  category TEXT NOT NULL,
  priority TEXT NOT NULL,
  sentiment TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('resolved', 'escalated')),
  summary TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

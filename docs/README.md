# 🤖 AI Customer Support Agent

**RAG-powered support agent that answers customers 24/7 from your own knowledge base, auto-triages every ticket, and escalates hard cases to your human team.**

Built with **n8n · OpenAI (GPT-5) · Supabase (pgvector)**

---

## 📌 Overview

This is an end-to-end AI customer support system for an e-commerce store (*"Nimbus Store"*). A customer opens a chat widget, asks a question, and the AI agent responds instantly — grounded strictly in the company's real policies, not generic AI guesses.

Every conversation is logged as a structured ticket, and anything the AI can't (or shouldn't) handle alone — angry customers, refund disputes, unknown questions — is automatically escalated to the support team on Discord.

---

## ✨ Key Features

| Feature | What it does |
|---|---|
| 🔎 **RAG (Retrieval-Augmented Generation)** | Answers are grounded in the company FAQ/policies stored in a Supabase vector database. The agent **must** search the knowledge base before answering policy questions — it never invents policies. |
| 🧠 **Conversation Memory** | Remembers the last several messages so customers don't have to repeat context. |
| 🗂️ **Automatic Triage** | Every message is classified: `category`, `priority`, `sentiment`, and a one-line `ticket_summary`. |
| 📝 **Ticket Logging** | Each interaction is written to a Data Table (resolved vs. escalated) for a full audit trail. |
| 🚨 **Smart Escalation** | Negative sentiment, refund/billing disputes, out-of-scope questions, or explicit "talk to a human" requests trigger a **Discord alert** to the team. |
| 💬 **Always Replies** | Whether escalated or not, the customer always receives a clean, friendly answer. |

---

## 🏗️ How It Works

The workflow has **two branches**:

### 1) Knowledge Base Ingestion *(run once, or whenever docs change)*
```
Company FAQ & Policies  →  Chunk Text  →  Embed (OpenAI)  →  Store in Supabase (vector DB)
```
Loads the company's policies into the vector store so the agent can retrieve them later.

### 2) Live Support Agent *(runs on every customer message)*
```
Customer Chat
      ↓
AI Support Agent  ──(uses)──►  Knowledge Base tool (RAG) + Memory + GPT-5 + Structured Output
      ↓
Save Ticket to Log
      ↓
Needs Human Handoff?
   ├─ Yes → Escalate to Discord → Reply to customer
   └─ No  → Reply to customer
```

---

## 🧩 Tech Stack

- **n8n** — workflow orchestration
- **OpenAI GPT-5 mini** — the reasoning/chat model
- **OpenAI Embeddings** — vectorizing documents & queries
- **Supabase (pgvector)** — vector knowledge base for RAG
- **n8n Data Table** — ticket logging
- **Discord** — human escalation channel

---

## 📊 Structured Output

For every message, the agent returns:

```json
{
  "answer": "Our standard shipping takes 3–5 business days.",
  "category": "shipping",
  "priority": "low",
  "sentiment": "neutral",
  "needs_human": false,
  "ticket_summary": "Customer asked how long shipping takes."
}
```

The `answer` goes to the customer; the rest powers logging and escalation.

---

## 🎯 Why It's Useful

- **24/7 instant support** — no wait times, no missed messages
- **Lower support costs** — routine questions handled automatically
- **No hallucinated answers** — responses are tied to your real policies
- **Nothing slips through** — hard/angry cases always reach a human
- **Full visibility** — every ticket categorized and logged

---

## ⚙️ Setup Notes

1. Create the Supabase `documents` table + `match_documents()` function (pgvector).
2. Add credentials in n8n: OpenAI, Supabase, Discord.
3. Run the **Knowledge Base Ingestion** branch once to load your docs.
4. Point your embedding model's vector size to match Supabase (`1536` for `text-embedding-3-small`).
5. Publish the chat trigger and share the widget link.

---

*Built by **Harmain Rizwan** — AI automation & workflow engineering.*

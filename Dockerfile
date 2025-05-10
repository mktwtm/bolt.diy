### Stage "base": instala pnpm e dependências
ARG BASE=node:20.18.0
FROM ${BASE} AS base

WORKDIR /app

# Copia apenas package.json e lockfile para cache de dependências
COPY package.json pnpm-lock.yaml ./

# Instala pnpm globalmente e as dependências do projeto
RUN npm install -g pnpm \
    && pnpm install --frozen-lockfile

# Copia o restante do código
COPY . .

# Exponha a porta usada pelo Bolt.diy
EXPOSE 5173

### Stage "bolt-ai-production": build de produção
FROM base AS bolt-ai-production

# Argumentos de build para injetar chaves/API
ARG GROQ_API_KEY
ARG HUGGINGFACE_API_KEY
ARG OPENAI_API_KEY
ARG ANTHROPIC_API_KEY
ARG OPEN_ROUTER_API_KEY
ARG GOOGLE_GENERATIVE_AI_API_KEY
ARG OLLAMA_API_BASE_URL
ARG XAI_API_KEY
ARG TOGETHER_API_KEY
ARG TOGETHER_API_BASE_URL
ARG AWS_BEDROCK_CONFIG
ARG VITE_LOG_LEVEL=debug
ARG DEFAULT_NUM_CTX=32768

# Variáveis de ambiente para runtime
ENV WRANGLER_SEND_METRICS=false \
    GROQ_API_KEY=${GROQ_API_KEY} \
    HUGGINGFACE_API_KEY=${HUGGINGFACE_API_KEY} \
    OPENAI_API_KEY=${OPENAI_API_KEY} \
    ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY} \
    OPEN_ROUTER_API_KEY=${OPEN_ROUTER_API_KEY} \
    GOOGLE_GENERATIVE_AI_API_KEY=${GOOGLE_GENERATIVE_AI_API_KEY} \
    OLLAMA_API_BASE_URL=${OLLAMA_API_BASE_URL} \
    XAI_API_KEY=${XAI_API_KEY} \
    TOGETHER_API_KEY=${TOGETHER_API_KEY} \
    TOGETHER_API_BASE_URL=${TOGETHER_API_BASE_URL} \
    AWS_BEDROCK_CONFIG=${AWS_BEDROCK_CONFIG} \
    VITE_LOG_LEVEL=${VITE_LOG_LEVEL} \
    DEFAULT_NUM_CTX=${DEFAULT_NUM_CTX} \
    RUNNING_IN_DOCKER=true

# Desativa métrica do Wrangler
RUN mkdir -p /root/.config/.wrangler \
    && echo '{"enabled":false}' > /root/.config/.wrangler/metrics.json

# Executa o build para produção
RUN pnpm run build

# Comando padrão para iniciar em produção
CMD ["pnpm", "run", "dockerstart"]

### Stage "bolt-ai-development": servidor dev
FROM base AS bolt-ai-development

# Modo watch
CMD ["pnpm", "run", "dev", "--host"]

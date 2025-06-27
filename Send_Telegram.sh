#!/bin/bash
# --- CONFIGURAÇÕES ---
BOT_TOKEN="XXX" # Token do Bot
CHAT_ID="YYY" # ID do super Canal
THREAD_ID="ZZZ" # ID do Canal
LOG_FILE="/var/log/pihole/pihole.log"
# --- Data de hoje no formato do log ---
DATA_ATUAL=$(date "+%b %e")
# --- Estatísticas básicas ---
TOTAL_CONSULTAS=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[" | wc -l)
TIPO_A=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[A\]" | wc -l)
TIPO_AAAA=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[AAAA\]" | wc -l)
TIPO_HTTPS=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[HTTPS\]" | wc -l)
TIPO_SRV=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[SRV\]" | wc -l)
TIPO_TXT=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[TXT\]" | wc -l)
# --- Top 5 IPs que mais consultaram ---
TOP_IPS=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[" | grep -oP 'from \K[\d\.]+' | sort | uniq -c | sort -nr | head -n 5)
# --- Top 5 domínios consultados ---
TOP_DOMINIOS=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "query\[" | grep -oP 'query\[\w+\] \K[^ ]+' | sort | uniq -c | sort -nr | head -n 5)
# --- Top 5 domínios bloqueados ---
TOP_BLOQUEADOS=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep "gravity blocked" | grep -oP 'gravity blocked \K[^ ]+' | sort | uniq -c | sort -nr | head -n 5)
# --- Total de bloqueios ---
TOTAL_BLOQUEIOS=$(grep "$DATA_ATUAL" "$LOG_FILE" | grep -c "gravity blocked")
# --- Monta a mensagem ---
MESSAGE="📊 *Estatísticas LABORATORIOS - Hoje ($(date +%d/%m/%Y))*
*Consultas totais:* $TOTAL_CONSULTAS
Tipo A: $TIPO_A
Tipo AAAA: $TIPO_AAAA
Tipo HTTPS: $TIPO_HTTPS
Tipo SRV: $TIPO_SRV
Tipo TXT: $TIPO_TXT

*Top 5 IPs que mais consultaram:*
\`\`\`
$TOP_IPS
\`\`\`

*Top 5 domínios consultados:*
\`\`\`
$TOP_DOMINIOS
\`\`\`

*Top 5 domínios bloqueados:*
\`\`\`
$TOP_BLOQUEADOS
\`\`\`

*Total de bloqueios:* $TOTAL_BLOQUEIOS"

# --- Envia a mensagem ---
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d message_thread_id="$THREAD_ID" \
    -d text="$MESSAGE" \
    -d parse_mode="Markdown" > /dev/null

# On Music — como colocar no ar

O app é um site que pode ser instalado no celular (PWA). Ele não precisa de compilação: os arquivos desta pasta já são o app pronto.

## O que tem na pasta

| Arquivo | Para que serve |
|---|---|
| `index.html` | O aplicativo inteiro |
| `config.js` | Onde você cola as chaves do Supabase e do Jamendo |
| `supabase.sql` | Cria o banco de dados, as permissões e o espaço para os áudios |
| `termos.html` | Rascunho dos Termos de Uso e da Política de Privacidade |
| `manifest.json`, `sw.js`, `icons/` | Permitem instalar o app no celular e abrir mais rápido |

## Passo 1 — Colocar no ar (10 minutos, grátis)

1. Descompacte o arquivo `onmusic-app.zip` no computador.
2. Acesse **app.netlify.com** e crie uma conta grátis (pode entrar com o Google).
3. Vá em **Sites → Add new site → Deploy manually**.
4. Arraste a pasta `onmusic-app` inteira para a área indicada.
5. Pronto: o Netlify gera um link como `nome-aleatorio.netlify.app`.
6. Em **Site configuration → Change site name**, troque o nome para algo como `onmusic-garca` → o link vira `onmusic-garca.netlify.app`.

Neste ponto já funcionam as rádios ao vivo, as músicas do celular, o player e o visual completo. Enquetes, agenda, anúncios e Oncast aparecem com dados de exemplo até o Passo 2.

Para atualizar o app depois: em **Deploys**, arraste a pasta de novo.

## Passo 2 — Banco de dados (Supabase, grátis)

1. Acesse **supabase.com**, crie uma conta e clique em **New project** (escolha a região São Paulo).
2. No menu da esquerda, abra **SQL Editor**, cole todo o conteúdo de `supabase.sql` e clique em **Run**.
3. Abra **Project Settings → API** e copie:
   - **Project URL**
   - **anon public key**
4. Cole os dois em `config.js`, entre as aspas:
   ```js
   SUPABASE_URL: "https://xxxx.supabase.co",
   SUPABASE_ANON_KEY: "eyJ...",
   ```
5. Arraste a pasta de novo no Netlify para atualizar.

A partir daí:
- Artistas publicam músicas de verdade, e elas ficam disponíveis para todo mundo.
- Os votos das enquetes são somados de todos os usuários.
- Denúncias, pedidos de anunciantes e sugestões de evento chegam no seu painel.

## Passo 3 — Administrar o conteúdo (pelo painel do Supabase)

Tudo pelo **Table Editor**, como uma planilha:

| Tabela | O que fazer |
|---|---|
| `eventos` | Adicionar eventos da agenda (data, hora, título, local, categoria) |
| `anuncios` | Cadastrar anunciantes, oferta, cupom e cor; desmarcar `ativo` para tirar do ar |
| `enquetes` | Criar perguntas; em `opcoes` digite `{"Opção 1","Opção 2"}` |
| `episodios` | Cadastrar episódios do Oncast (veja abaixo) |
| `denuncias` | Ver denúncias; para remover a faixa, mude o `status` dela para `oculta` em `faixas` |
| `pedidos_anuncio` / `sugestoes_evento` | Contatos de anunciantes e sugestões do público |

**Episódios do Oncast:** em **Storage → oncast**, envie o áudio do episódio (MP3). Clique no arquivo, copie a URL pública e cole em `audio_url` na tabela `episodios`, junto com o link do post no Instagram ou Facebook. A importação automática pela API da Meta pode ser feita mais tarde: exige o Instagram como conta profissional ligado à página do Facebook.

## Passo 4 (opcional) — Catálogo livre com músicas reais

Crie uma conta grátis em **devportal.jamendo.com**, gere um **Client ID** e cole em `JAMENDO_CLIENT_ID` no `config.js`. O catálogo passa a mostrar músicas Creative Commons em vez das faixas de demonstração.

## Passo 5 — Google Play

1. Com o app no ar, acesse **pwabuilder.com** e cole o link do site.
2. Clique em **Package for stores → Android** e baixe o pacote.
3. Crie a conta de desenvolvedor no **Google Play Console** (taxa única de US$ 25) e envie o pacote seguindo as instruções do PWABuilder.

## Antes de divulgar

- Revise o `termos.html` com um advogado.
- Hoje qualquer pessoa pode publicar uma música sem login. Para evitar spam quando o app crescer, o próximo passo é exigir que o artista confirme o e-mail antes de publicar.

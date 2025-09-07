# 🐳 Multi‑Stage Dockerfile — Line‑by‑Line Notes (with Emojis)

This guide explains exactly what each line in your **multi‑stage Dockerfile** does and why it’s ordered this way.

---

## 📄 Full Dockerfile

```dockerfile
# ---------- client build ----------
FROM node:18-alpine AS client-build
WORKDIR /app/client
COPY client/package*.json ./
RUN npm ci --no-audit --no-fund
COPY client/ ./
RUN npm run build

# ---------- server runtime ----------
FROM node:18-alpine
WORKDIR /app/server

# Only server deps
COPY server/package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund

# Server source
COPY server/ ./

# Bring in built client assets
COPY --from=client-build /app/client/dist/ ./public/

EXPOSE 5000
CMD ["npm","start"]
```

---

## 🔧 Stage 1 — Client Build (named `client-build`)

```dockerfile
FROM node:18-alpine AS client-build
```

* 🧱 **Base image**: Uses a small Alpine Linux image with Node.js 18.
* 🏷️ **Stage name**: `AS client-build` labels this stage so later stages can copy artifacts from it.

```dockerfile
WORKDIR /app/client
```

* 📁 **Working directory**: All following `COPY`/`RUN` commands operate inside `/app/client`.

```dockerfile
COPY client/package*.json ./
```

* 📥 **Copy manifests first**: Brings in `package.json` and `package-lock.json` only.
* 🚀 **Layer caching**: If code changes but lockfiles don’t, the `npm ci` layer can be reused.

```dockerfile
RUN npm ci --no-audit --no-fund
```

* ⚙️ **Deterministic install**: `npm ci` installs exactly from the lockfile and wipes `node_modules` first.
* ⏩ **Faster builds**: `--no-audit --no-fund` skips extra steps/output.

```dockerfile
COPY client/ ./
```

* 🧩 **Copy source**: Brings in the rest of the client code after dependencies to preserve cache benefits.

```dockerfile
RUN npm run build
```

* 🏗️ **Build frontend**: Produces an optimized static bundle (typically in `/app/client/dist`).

---

## 🧊 Stage 2 — Final Server Runtime Image

```dockerfile
FROM node:18-alpine
```

* 🧼 **Fresh runtime**: Starts a clean image without the build tools, keeping the final image smaller and more secure.

```dockerfile
WORKDIR /app/server
```

* 📁 **Server working dir**: All server commands/files live under `/app/server`.

```dockerfile
COPY server/package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund
```

* 📥 **Server manifests first**: Copy only `package.json`/`package-lock.json` to leverage cache.
* ✂️ **Prod‑only deps**: `--omit=dev` excludes devDependencies for a slimmer runtime layer.

```dockerfile
COPY server/ ./
```

* 📦 **Server code**: Copies Express/Koa/etc. application files into the image.

```dockerfile
COPY --from=client-build /app/client/dist/ ./public/
```

* 🔗 **Bring built assets**: Copies the client’s production bundle from the `client-build` stage into `./public/` where Express typically serves static files (`app.use(express.static('public'))`).

```dockerfile
EXPOSE 5000
```

* 🔌 **Port documentation**: Declares the container listens on port 5000 (use `-p 5000:5000` to publish it when running).

```dockerfile
CMD ["npm","start"]
```

* 🚀 **Startup command**: Runs the server via the `start` script (often `node server.js`).

---

## 💡 Why this order?

* 🔁 **Caching**: Copy lockfiles → install deps → then copy code. Edits to code don’t bust the (expensive) dependency layer.
* 🧳 **Smaller final image**: Multi‑stage copies only the **built** client assets + server runtime deps into the final image.

---

## 🧪 Sanity Checks & Tips

* 🌍 Ensure the server binds to `0.0.0.0:5000` (not `localhost`) so it’s reachable from outside the container.
* 🗂️ If your client outputs to `build/` (e.g., CRA), change the copy path:

  ```dockerfile
  COPY --from=client-build /app/client/build/ ./public/
  ```
* 🧱 Alpine native modules: if build fails on native addons, add tools **in the build stage**:

  ```dockerfile
  RUN apk add --no-cache python3 make g++
  ```
* 🧹 `.dockerignore`: exclude `node_modules`, `.git`, and local build artifacts to speed up context send.

---

## ▶️ Run & Test

```bash
# Build image
docker build -t three-tier:ms .

# Run container (publish port)
docker run --rm -p 5000:5000 three-tier:ms

# Test from host
curl -I http://localhost:5000/
```

**Expected:** `HTTP/1.1 200 OK` with static assets served from `/app/server/public` and API routes available under your configured paths.

---

## 📝 TL;DR

* 🏗️ Stage 1 builds the client → outputs to `/app/client/dist`.
* 🚚 Stage 2 copies server code + **built** client assets into `/app/server/public`.
* 🪄 `npm ci` + manifest‑first copy = faster, reproducible builds.
* 📦 Final image is smaller and production‑ready. 🎯

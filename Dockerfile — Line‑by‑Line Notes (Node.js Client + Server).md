# 🐳 Dockerfile — Line‑by‑Line Notes (Node.js Client + Server)

Below is the Dockerfile followed by a **line‑by‑line explanation** of what each directive does and why.
Bonus notes at the end on caching, `npm ci` vs `npm install`, and common pitfalls.

---

## 📄 Full Dockerfile

```dockerfile
# Use an alpine Node.js runtime as a parent image
FROM node:18-alpine

# ===== Client =====
# Set the working directory for the client
WORKDIR /usr/src/app/client

# Copy the client package.json / package-lock.json and install deps
COPY client/package*.json ./
RUN npm ci --no-audit --no-fund

# Copy client source and build
COPY client/ ./
RUN npm run build

# ===== Server =====
# Set the working directory for the server
WORKDIR /usr/src/app/server

# Copy the server package.json / package-lock.json and install deps
COPY server/package*.json ./
RUN npm ci --no-audit --no-fund

# Copy the server source
COPY server/ ./

# Copy the client build into the server's public dir
RUN mkdir -p ./public && cp -R /usr/src/app/client/dist/* ./public/

# Expose API port
EXPOSE 5000

# Start the server
CMD ["npm","start"]
```

---

## 🔍 Line‑by‑Line Explanation

### 1) Base image

* `FROM node:18-alpine`
  🧱 **Choose runtime**: pulls a small Alpine‑based image with Node.js 18.
  ⚖️ Trade‑off: Alpine is tiny, but some native modules may need `build-base`/`python3` to compile. If you hit build issues, switch to `node:18` (Debian) or add build tools.

### 2) Client stage (still single‑stage image)

* `WORKDIR /usr/src/app/client`
  📁 **Sets current folder** inside the image. Subsequent `COPY`/`RUN` occur here. Docker creates it if missing.

* `COPY client/package*.json ./`
  📥 **Copy only dependency manifests** first. This lets Docker **cache** the `npm ci` layer as long as lockfiles don’t change. Pattern `package*.json` matches `package.json` & `package-lock.json`.

* `RUN npm ci --no-audit --no-fund`
  ⚙️ **Install exact deps** from lockfile. Faster, reproducible, and fails if lockfile and package.json disagree. Flags skip audit/fund prompts to keep builds quiet & fast.

* `COPY client/ ./`
  📦 **Bring in the rest of the client source** (React/Vue/etc.). This is placed after deps so code edits don’t invalidate the dependency cache.

* `RUN npm run build`
  🏗️ **Produce static assets** (e.g., `client/dist/`). These are later served by the Node server from a `/public` folder.

### 3) Server stage (same image continues)

* `WORKDIR /usr/src/app/server`
  📁 **Switch working directory** to the server app.

* `COPY server/package*.json ./`
  📥 **Server dependency manifests** copied first (again for caching benefits).

* `RUN npm ci --no-audit --no-fund`
  ⚙️ **Install server deps** exactly as locked.

* `COPY server/ ./`
  📦 **Copy server source** into the image (Express/Koa/etc.).

### 4) Serve built client via server

* `RUN mkdir -p ./public && cp -R /usr/src/app/client/dist/* ./public/`
  🔗 **Publish client bundle**: ensure `./public` exists, then copy the built client files from the client workspace into the server’s `public` directory so your Node server can serve them (e.g., `app.use(express.static('public'))`).
  📝 `-R` copies recursively; adjust paths if your build directory differs.

  [Serving Frontend in Node/Express: dist/ vs public/ (with Docker)](./Serving%20Frontend%20in%20NodeExpress%20dist%20vs%20public%20(with%20Docker).md)

### 5) Runtime settings

* `EXPOSE 5000`
  🔌 **Documentation hint**: declares that the container listens on port 5000. It doesn’t publish the port by itself—use `-p 5000:5000` or Compose to map it on the host.

* `CMD ["npm","start"]`
  🚀 **Default startup command** when the container runs. Typically this runs something like `node server.js` via your `package.json` `start` script.
  🧠 You can override with `docker run … <other command>` if needed.

---

## 💡 Why the order matters (Layer caching)

* Copying only `package*.json` **before** the rest of the source lets Docker cache the dependency install layers.
* When you change app code (but not dependencies), Docker reuses the cached layers, making rebuilds much faster. ⚡

---

## 🧪 `npm ci` vs `npm install`

* **`npm ci`**: installs exactly what’s in `package-lock.json`, fails if lockfile mismatch, faster for CI/containers.  Deletes any existing node_modules/ and Fails if package.json and package-lock.json disagree.✅
* **`npm install`**: can update the lockfile; slower and less deterministic in builds. ❌ for reproducible images.

---

## 📦 Single‑stage vs Multi‑stage

* This Dockerfile is **single‑stage**: final image contains everything used during the client build (tooling, caches).
* For smaller images, use a **multi‑stage** build: build client in one stage, copy only its `dist/` into a slim runtime stage with just the server deps. 🧊

---

## 🛡️ Common pitfalls & fixes

* 🔧 **Native modules fail on Alpine** → add build tools: `apk add --no-cache python3 make g++` or move to `node:18` (Debian).
* 📂 **Wrong client build path** → verify it’s `client/dist/` (some frameworks use `build/`).
* 🌐 **Nothing on port 5000** → ensure `npm start` actually listens on `0.0.0.0:5000` inside the container; not just `localhost`.
* 🔁 **Rebuild after lockfile change** → cache will invalidate and deps reinstall (expected).
* 🔒 **Permissions in CI** → consider `RUN npm ci --unsafe-perm` if scripts need it (rare).

---

### ✅ Quick run (example)

```bash
# Build
docker build -t three-tier:dev .

# Run (map port 5000)
docker run --rm -p 5000:5000 three-tier:dev
```

Happy shipping! 🚢✨

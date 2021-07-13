# deps

FROM node:14-alpine AS deps

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

# final container

FROM node:14-alpine

WORKDIR /app

ENV NODE_ENV production
ENV PORT 3000

COPY package.json .
COPY --from=deps /app/node_modules node_modules
COPY index.js /app/
EXPOSE $PORT

CMD ["npm", "run", "start"]

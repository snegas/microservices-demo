FROM node:lts-alpine as base

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY package* .

RUN npm ci --only=production

FROM node:lts-alpine as result

ENV PORT 5555
ENV DISABLE_PROFILER 1

EXPOSE ${PORT}

WORKDIR /app

COPY --from=base /app/node_modules ./node_modules

COPY . .

ENTRYPOINT ["node", "index.js"]
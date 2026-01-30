FROM node:18-alpine

WORKDIR /app

COPY app/package.json .

RUN npm install --production

COPY app/server.js .

EXPOSE 8080

USER node

CMD ["npm", "start"]

FROM node:18-alpine

WORKDIR /app

COPY app/ .

EXPOSE 8080

USER node

CMD ["npm", "start"]

FROM node:alpine

WORKDIR /opt/app
COPY package*.json ./
RUN npm install
ADD . .
CMD ["npm", "start"]
# build environment
FROM node:13.12.0-alpine as build
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY ./package*.json ./
RUN npm install
COPY . ./
RUN npm run build

# production environment
# Declare a build argument with a default value
ARG IMAGE_TAG=react_calculator
# Use the build argument to label the image
LABEL version=$IMAGE_TAG
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
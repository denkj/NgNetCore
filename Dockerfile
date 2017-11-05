FROM microsoft/aspnetcore-build:2.0 AS build-env

WORKDIR /app
ENV NODE_VERSION 8.9.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -zxvf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
    && npm install -g webpack yarn

COPY *.csproj ./
RUN dotnet restore

COPY package.json yarn.lock ./
RUN yarn install

COPY . ./
RUN webpack \
    && dotnet publish -o out

FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "NgNetCore.dll"]

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["dotnet-hello-world.csproj", "."]
RUN dotnet restore "dotnet-hello-world.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "dotnet-hello-world.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dotnet-hello-world.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create non-root user
RUN groupadd -r dotnet && useradd -r -g dotnet dotnet
RUN chown -R dotnet:dotnet /app
USER dotnet

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

ENTRYPOINT ["dotnet", "dotnet-hello-world.dll"]
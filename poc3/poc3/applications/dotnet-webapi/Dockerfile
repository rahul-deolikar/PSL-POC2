(cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF'
diff --git a/poc3/applications/dotnet-webapi/Dockerfile b/poc3/applications/dotnet-webapi/Dockerfile
--- a/poc3/applications/dotnet-webapi/Dockerfile
+++ b/poc3/applications/dotnet-webapi/Dockerfile
@@ -0,0 +1,50 @@
+# Build stage
+FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
+WORKDIR /app
+
+# Copy project file and restore dependencies
+COPY *.csproj ./
+RUN dotnet restore
+
+# Copy source code and build
+COPY . ./
+RUN dotnet publish -c Release -o out --no-restore
+
+# Runtime stage
+FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
+
+# Set environment variables
+ENV ASPNETCORE_ENVIRONMENT=Production
+ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
+ENV PORT=5000
+
+# Create non-root user for security
+RUN groupadd -r appuser && useradd -r -g appuser appuser
+
+# Set working directory
+WORKDIR /app
+
+# Copy published application from build stage
+COPY --from=build /app/out .
+
+# Change ownership to non-root user
+RUN chown -R appuser:appuser /app
+
+# Switch to non-root user
+USER appuser
+
+# Expose port
+EXPOSE 5000
+
+# Health check
+HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
+    CMD curl -f http://localhost:5000/health || exit 1
+
+# Add labels for better container management
+LABEL maintainer="poc3-team@example.com" \
+      version="1.0.0" \
+      description="POC3 .NET Core Web API Hello World Application" \
+      org.opencontainers.image.source="https://github.com/your-org/poc3"
+
+# Start the application
+ENTRYPOINT ["dotnet", "Poc3.DotNet.WebApi.dll"]
EOF
)

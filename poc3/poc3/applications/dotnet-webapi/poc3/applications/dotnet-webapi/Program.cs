(cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF'
diff --git a/poc3/applications/dotnet-webapi/Program.cs b/poc3/applications/dotnet-webapi/Program.cs
--- a/poc3/applications/dotnet-webapi/Program.cs
+++ b/poc3/applications/dotnet-webapi/Program.cs
@@ -0,0 +1,251 @@
+using Microsoft.AspNetCore.Mvc;
+using System.Text.Json.Serialization;
+
+var builder = WebApplication.CreateBuilder(args);
+
+// Add services to the container
+builder.Services.AddControllers()
+    .AddJsonOptions(options =>
+    {
+        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
+        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
+    });
+
+builder.Services.AddEndpointsApiExplorer();
+builder.Services.AddSwaggerGen(c =>
+{
+    c.SwaggerDoc("v1", new() 
+    { 
+        Title = "POC3 .NET Core Web API", 
+        Version = "v1.0.0",
+        Description = "Complete CI/CD pipeline demonstration with .NET Core Web API"
+    });
+});
+
+builder.Services.AddHealthChecks();
+builder.Services.AddCors(options =>
+{
+    options.AddDefaultPolicy(builder =>
+    {
+        builder.AllowAnyOrigin()
+               .AllowAnyMethod()
+               .AllowAnyHeader();
+    });
+});
+
+var app = builder.Build();
+
+// Configure the HTTP request pipeline
+if (app.Environment.IsDevelopment() || app.Environment.IsProduction())
+{
+    app.UseSwagger();
+    app.UseSwaggerUI(c =>
+    {
+        c.SwaggerEndpoint("/swagger/v1/swagger.json", "POC3 .NET Core Web API v1");
+        c.RoutePrefix = "swagger";
+    });
+}
+
+app.UseCors();
+app.UseRouting();
+app.MapControllers();
+app.MapHealthChecks("/health");
+
+// Root endpoint with HTML
+app.MapGet("/", () => Results.Content("""
+<!DOCTYPE html>
+<html lang="en">
+<head>
+    <meta charset="UTF-8">
+    <meta name="viewport" content="width=device-width, initial-scale=1.0">
+    <title>POC3 - .NET Core Web API Hello World</title>
+    <style>
+        body {
+            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
+            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
+            margin: 0;
+            padding: 0;
+            min-height: 100vh;
+            display: flex;
+            align-items: center;
+            justify-content: center;
+        }
+        .container {
+            background: white;
+            border-radius: 20px;
+            padding: 40px;
+            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
+            text-align: center;
+            max-width: 600px;
+            margin: 20px;
+        }
+        .logo { font-size: 3em; margin-bottom: 20px; }
+        h1 { color: #333; margin-bottom: 10px; }
+        .subtitle { color: #666; margin-bottom: 30px; }
+        .tech-stack {
+            display: flex;
+            justify-content: center;
+            gap: 15px;
+            margin: 30px 0;
+            flex-wrap: wrap;
+        }
+        .tech-item {
+            background: #f0f0f0;
+            padding: 10px 20px;
+            border-radius: 25px;
+            font-size: 14px;
+            color: #555;
+        }
+        .api-info {
+            background: #f8f9fa;
+            border-radius: 10px;
+            padding: 20px;
+            margin-top: 30px;
+            text-align: left;
+        }
+        .endpoint {
+            background: #e9ecef;
+            padding: 8px 12px;
+            border-radius: 5px;
+            font-family: monospace;
+            margin: 5px 0;
+            display: block;
+        }
+        .status {
+            display: inline-block;
+            background: #28a745;
+            color: white;
+            padding: 5px 15px;
+            border-radius: 15px;
+            font-size: 12px;
+            margin-top: 10px;
+        }
+        .docs-link {
+            background: #007bff;
+            color: white;
+            padding: 10px 20px;
+            border-radius: 5px;
+            text-decoration: none;
+            display: inline-block;
+            margin: 10px 5px;
+        }
+    </style>
+</head>
+<body>
+    <div class="container">
+        <div class="logo">⚡</div>
+        <h1>POC3 Hello World</h1>
+        <div class="subtitle">.NET Core Web API Application</div>
+        
+        <div class="tech-stack">
+            <div class="tech-item">.NET Core 8</div>
+            <div class="tech-item">ASP.NET Core</div>
+            <div class="tech-item">Swagger/OpenAPI</div>
+            <div class="tech-item">Docker</div>
+            <div class="tech-item">AWS ECS</div>
+        </div>
+
+        <div class="api-info">
+            <h3>🔗 Available API Endpoints</h3>
+            <code class="endpoint">GET /health - Health check</code>
+            <code class="endpoint">GET /api/hello - Hello world message</code>
+            <code class="endpoint">GET /api/info - Application information</code>
+            <code class="endpoint">GET /swagger - Swagger UI</code>
+            
+            <div style="margin-top: 15px;">
+                <strong>🔒 Security Scanning:</strong> SAST, DAST, SCA Enabled<br>
+                <strong>📦 Artifacts:</strong> ECR, JFrog, S3<br>
+                <strong>🚀 Deployment:</strong> Octopus Deploy → AWS ECS
+            </div>
+            
+            <div style="margin-top: 20px;">
+                <a href="/swagger" class="docs-link">📚 Swagger UI</a>
+                <a href="/swagger/v1/swagger.json" class="docs-link">📋 OpenAPI JSON</a>
+            </div>
+            
+            <span class="status">✅ Active</span>
+        </div>
+    </div>
+</body>
+</html>
+""", "text/html"));
+
+var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
+Console.WriteLine($"🚀 POC3 .NET Core Web API listening on port {port}");
+Console.WriteLine($"📍 Health check: http://localhost:{port}/health");
+Console.WriteLine($"🌐 API endpoint: http://localhost:{port}/api/hello");
+Console.WriteLine($"📚 Swagger UI: http://localhost:{port}/swagger");
+
+app.Run($"http://0.0.0.0:{port}");
+
+// Models
+public record HelloResponse(
+    string Message,
+    string Timestamp,
+    string Environment,
+    string Service
+);
+
+public record InfoResponse(
+    string Application,
+    string Version,
+    List<string> Technologies,
+    string Description,
+    List<EndpointInfo> Endpoints
+);
+
+public record EndpointInfo(
+    string Path,
+    string Method,
+    string Description
+);
+
+// Controller
+[ApiController]
+[Route("api")]
+public class HelloController : ControllerBase
+{
+    private readonly IConfiguration _configuration;
+    private readonly IWebHostEnvironment _environment;
+
+    public HelloController(IConfiguration configuration, IWebHostEnvironment environment)
+    {
+        _configuration = configuration;
+        _environment = environment;
+    }
+
+    [HttpGet("hello")]
+    public ActionResult<HelloResponse> GetHello()
+    {
+        var response = new HelloResponse(
+            "Hello World from .NET Core Web API POC3!",
+            DateTime.UtcNow.ToString("O"),
+            _environment.EnvironmentName,
+            "dotnet-webapi-api"
+        );
+        
+        return Ok(response);
+    }
+
+    [HttpGet("info")]
+    public ActionResult<InfoResponse> GetInfo()
+    {
+        var endpoints = new List<EndpointInfo>
+        {
+            new("/health", "GET", "Health check endpoint"),
+            new("/api/hello", "GET", "Hello world message"),
+            new("/api/info", "GET", "Application information"),
+            new("/swagger", "GET", "Swagger UI documentation")
+        };
+
+        var response = new InfoResponse(
+            "POC3 .NET Core Web API Hello World",
+            "1.0.0",
+            new List<string> { ".NET Core 8", "ASP.NET Core", "Swagger/OpenAPI", "Docker" },
+            "Complete CI/CD pipeline demonstration with .NET Core Web API",
+            endpoints
+        );
+
+        return Ok(response);
+    }
+}
EOF
)

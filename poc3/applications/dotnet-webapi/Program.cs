using Microsoft.OpenApi.Models;
using System.ComponentModel.DataAnnotations;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo 
    { 
        Title = ".NET Core Hello World API", 
        Version = "v1",
        Description = "Hello World API for TeamCity CI/CD Pipeline"
    });
});

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(
        policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

// Define API endpoints
app.MapGet("/", () => new
{
    service = ".NET Core Hello World API",
    version = "1.0.0",
    endpoints = new[]
    {
        "GET /health - Health check",
        "GET /api/hello - Hello World message",
        "GET /api/hello/{name} - Personalized hello message",
        "GET /swagger - API documentation"
    }
});

app.MapGet("/api/hello", () => new HelloResponse(
    "Hello World from .NET Core!",
    "1.0.0",
    DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss"),
    ".NET Core + ASP.NET"
));

app.MapGet("/api/hello/{name}", (string name) =>
{
    if (string.IsNullOrWhiteSpace(name))
    {
        return Results.BadRequest("Name cannot be empty");
    }

    var response = new HelloResponse(
        $"Hello {name} from .NET Core!",
        "1.0.0",
        DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss"),
        ".NET Core + ASP.NET"
    );

    return Results.Ok(response);
});

app.Run();

public record HelloResponse(
    [Required] string Message,
    [Required] string Version,
    [Required] string Timestamp,
    [Required] string Technology
);
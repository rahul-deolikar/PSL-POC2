import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [message, setMessage] = useState('');
  const [name, setName] = useState('');
  const [apiResponse, setApiResponse] = useState(null);
  const [loading, setLoading] = useState(false);
  const [apis] = useState([
    { name: 'Node.js API', url: process.env.REACT_APP_NODEJS_API_URL || 'http://localhost:3000' },
    { name: '.NET API', url: process.env.REACT_APP_DOTNET_API_URL || 'http://localhost:5000' },
    { name: 'Java API', url: process.env.REACT_APP_JAVA_API_URL || 'http://localhost:8080' },
    { name: 'Python API', url: process.env.REACT_APP_PYTHON_API_URL || 'http://localhost:5001' }
  ]);

  const fetchHelloWorld = async (apiUrl, apiName) => {
    setLoading(true);
    try {
      const response = await axios.get(`${apiUrl}/api/hello?name=${name || 'World'}`);
      setApiResponse({
        api: apiName,
        data: response.data,
        status: response.status
      });
      setMessage(`Successfully connected to ${apiName}!`);
    } catch (error) {
      setApiResponse({
        api: apiName,
        error: error.message,
        status: error.response?.status || 'Connection failed'
      });
      setMessage(`Failed to connect to ${apiName}`);
    } finally {
      setLoading(false);
    }
  };

  const testAllApis = async () => {
    setLoading(true);
    const results = [];
    
    for (const api of apis) {
      try {
        const response = await axios.get(`${api.url}/health`, { timeout: 3000 });
        results.push({ ...api, status: 'healthy', data: response.data });
      } catch (error) {
        results.push({ ...api, status: 'error', error: error.message });
      }
    }
    
    setApiResponse({ allApis: results });
    setLoading(false);
  };

  useEffect(() => {
    setMessage('Welcome to POC3 Hello World Frontend!');
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 POC3 - Hello World Frontend</h1>
        <p className="subtitle">React.js Frontend connecting to multiple API backends</p>
        
        <div className="input-section">
          <input
            type="text"
            placeholder="Enter your name (optional)"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="name-input"
          />
        </div>

        <div className="api-buttons">
          {apis.map((api, index) => (
            <button
              key={index}
              onClick={() => fetchHelloWorld(api.url, api.name)}
              disabled={loading}
              className="api-button"
            >
              Test {api.name}
            </button>
          ))}
        </div>

        <button
          onClick={testAllApis}
          disabled={loading}
          className="test-all-button"
        >
          {loading ? '⏳ Testing...' : '🔍 Test All APIs Health'}
        </button>

        {message && (
          <div className="message">
            <p>{message}</p>
          </div>
        )}

        {apiResponse && (
          <div className="api-response">
            <h3>API Response:</h3>
            <pre>{JSON.stringify(apiResponse, null, 2)}</pre>
          </div>
        )}

        <footer className="app-footer">
          <p>POC3 - Comprehensive CI/CD Pipeline Demo</p>
          <p>Technologies: React.js, Node.js, .NET, Java, Python</p>
        </footer>
      </header>
    </div>
  );
}

export default App;
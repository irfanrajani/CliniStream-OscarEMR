<%@ page import="java.io.*, java.net.*, org.json.*" %>
<%@ page contentType="application/json" %>
<%
/**
 * NextScript Integration - Send SMS
 * Bridges OSCAR to integration service API
 */

response.setContentType("application/json");

try {
    // Get parameters from OSCAR
    String toNumber = request.getParameter("to");
    String message = request.getParameter("message");

    if (toNumber == null || toNumber.trim().isEmpty()) {
        response.setStatus(400);
        out.print("{\"error\":\"Missing 'to' parameter\"}");
        return;
    }

    if (message == null || message.trim().isEmpty()) {
        response.setStatus(400);
        out.print("{\"error\":\"Missing 'message' parameter\"}");
        return;
    }

    // Call integration service
    String integrationUrl = System.getenv("INTEGRATION_SERVICE_URL");
    if (integrationUrl == null) {
        integrationUrl = "http://integrations:8080";
    }

    URL url = new URL(integrationUrl + "/api/sms/send");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/json");
    conn.setDoOutput(true);

    // Build JSON request
    JSONObject jsonRequest = new JSONObject();
    jsonRequest.put("to", toNumber);
    jsonRequest.put("message", message);

    // Send request
    OutputStream os = conn.getOutputStream();
    os.write(jsonRequest.toString().getBytes("UTF-8"));
    os.flush();
    os.close();

    // Read response
    int responseCode = conn.getResponseCode();
    BufferedReader br = new BufferedReader(new InputStreamReader(
        responseCode == 200 ? conn.getInputStream() : conn.getErrorStream()
    ));

    StringBuilder responseStr = new StringBuilder();
    String line;
    while ((line = br.readLine()) != null) {
        responseStr.append(line);
    }
    br.close();

    response.setStatus(responseCode);
    out.print(responseStr.toString());

} catch (Exception e) {
    response.setStatus(500);
    JSONObject error = new JSONObject();
    error.put("error", e.getMessage());
    out.print(error.toString());
}
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- CSRF Token Input Field - Include this in all forms --%>
<input type="hidden" name="csrfToken" value="<%= session.getAttribute(\"csrfToken\") %>" />

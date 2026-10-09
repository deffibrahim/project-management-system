<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/dashboard/header.jsp" %>
<h2>Edit User</h2>
<c:if test="${not empty user}">
<form action="${pageContext.request.contextPath}/users/update" method="post">
    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}" />
    <input type="hidden" name="userId" value="${user.userId}" />
    <div class="form-group">
        <label for="name">Full Name</label>
        <input type="text" id="name" name="name" value="${fn:escapeXml(user.name)}" required maxlength="100" />
    </div>
    <div class="form-group">
        <label for="email">Email</label>
        <input type="email" id="email" name="email" value="${fn:escapeXml(user.email)}" required maxlength="100" />
    </div>
    <div class="form-group">
        <label for="role">Role</label>
        <select id="role" name="role" required>
            <option value="ADMIN" ${user.role == 'ADMIN' ? 'selected' : ''}>Admin</option>
            <option value="PROJECT_MANAGER" ${user.role == 'PROJECT_MANAGER' ? 'selected' : ''}>Project Manager</option>
            <option value="TEAM_MEMBER" ${user.role == 'TEAM_MEMBER' ? 'selected' : ''}>Team Member</option>
        </select>
    </div>
    <button type="submit" class="form-button">Update User</button>
</form>
</c:if>
<%@ include file="/dashboard/footer.jsp" %>

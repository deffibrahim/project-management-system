<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/dashboard/header.jsp" %>
<h2>Project Details</h2>
<c:if test="${not empty project}">
    <div class="project-info">
        <h3>${project.title}</h3>
        <p>${project.description}</p>
        <p><strong>Manager:</strong> ${project.managerId}</p>
        <p><strong>Start:</strong> ${project.startDate}</p>
        <p><strong>End:</strong> ${project.endDate}</p>
    </div>
    <h3>Tasks</h3>
    <a href="${pageContext.request.contextPath}/tasks/create?projectId=${project.projectId}" class="form-button">+ Add Task</a>
    <c:if test="${not empty tasks}">
        <table class="table">
            <thead>
                <tr><th>Title</th><th>Status</th><th>Assignee</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <c:forEach var="task" items="${tasks}">
                    <tr>
                        <td>${task.title}</td>
                        <td>${task.status}</td>
                        <td>${task.assigneeId}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/tasks/edit?id=${task.taskId}&projectId=${project.projectId}">Edit</a>
                            <form action="${pageContext.request.contextPath}/tasks/delete" method="post" style="display:inline;">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}" />
                                <input type="hidden" name="id" value="${task.taskId}" />
                                <input type="hidden" name="projectId" value="${project.projectId}" />
                                <button type="submit" class="link-button">Delete</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
</c:if>
<%@ include file="/dashboard/footer.jsp" %>

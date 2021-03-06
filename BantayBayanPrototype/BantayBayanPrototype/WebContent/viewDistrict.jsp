<!-- This .jsp file displays the data of a district account -->
<%@ page import="java.sql.*"%>
<%@ page import="com.bbp.*"%>

<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.LocalTime"%>
<%!printHtml printHtmlObj = new printHtml();%>

<%
	bbpDate bbpDateObj = new bbpDate();

	int[] pConcernID = new int[100];
	String[] pUser = new String[100];
	LocalDate[] ldObj = new LocalDate[100];
	LocalTime[] ltObj = new LocalTime[100];
	String[] pStatus = new String[100];
	String[] pReplystatus = new String[100];
	String[] pCategory = new String[100];
	String[] pRecipient = new String[100];
	String[] pDistrict = new String[100];
	String[] pSub = new String[100];
	String[] pBody = new String[100];
	String[] pAttachment = new String[100];
	int[] pRating = new int[100];

	int totalListSize = 0;
	String pFilter = "all";
	String pFilter2 = "postdate desc";
	if (request.getParameter("filter") != null) {
		pFilter = request.getParameter("filter");
	}
	if(request.getParameter("filter2") != null){
		pFilter2 = request.getParameter("filter2");
	}

	// get values passed from index.jsp
	String getConcernID = request.getParameter("concernID");
	String getTitle = request.getParameter("title");

	try {
		// 1. Register new jdbc driver
		DriverManager.registerDriver(new com.mysql.jdbc.Driver());
		// 2. Get a connection to database
		Connection myConn = DriverManager.getConnection(
				"jdbc:mysql://localhost:3306/bbp?useUnicode=yes&characterEncoding=UTF-8", "root",
				"33sqltestpass33");
		// 3. Create a statement (select username that matches the input)
		Statement myStmt = myConn.createStatement();
		
		// 4. getting total number of concerns in every filter
		ResultSet myRs = null;
		if (pFilter.equals("Unresolved") || pFilter.equals("Resolved")) {
			myRs = myStmt.executeQuery("SELECT COUNT(*) FROM tblConcerns WHERE district='" + getTitle
					+ "' AND concernStatus='" + pFilter + "' ORDER BY " + pFilter2 + ";");
		} else if (pFilter.equals("Not Replied")) {
			myRs = myStmt.executeQuery("SELECT COUNT(*) FROM tblConcerns WHERE district='" + getTitle
					+ "' AND replyStatus='" + pFilter + "' ORDER BY " + pFilter2 + ";");
		} else {
			myRs = myStmt.executeQuery("SELECT COUNT(*) FROM tblConcerns WHERE district='" + getTitle + "' ORDER BY " + pFilter2 + ";");
		}
		while (myRs.next()) {
			totalListSize = myRs.getInt("COUNT(*)");
		}
		
		// 5. filtering concerns and processing it to result set
		ResultSet myRs2 = null;
		if (pFilter.equals("Unresolved") || pFilter.equals("Resolved")) {
			myRs2 = myStmt.executeQuery("SELECT * FROM tblConcerns WHERE district='" + getTitle
					+ "' AND concernStatus='" + pFilter + "' ORDER BY " + pFilter2 + ";");
		} else if (pFilter.equals("Not Replied")) {
			myRs2 = myStmt.executeQuery("SELECT * FROM tblConcerns WHERE district='" + getTitle
					+ "' AND replyStatus='" + pFilter + "' ORDER BY " + pFilter2 + ";");
		} else {
			myRs2 = myStmt.executeQuery("SELECT * FROM tblConcerns WHERE district='" + getTitle + "' ORDER BY " + pFilter2 + ";");
		}

		int i = 0;
		while (myRs2.next()) {
			pConcernID[i] = myRs2.getInt("concernID");
			pSub[i] = myRs2.getString("sub");
			pCategory[i] = myRs2.getString("category");
			ldObj[i] = myRs2.getDate("postdate").toLocalDate();
			ltObj[i] = myRs2.getTime("postdate").toLocalTime();

			i++;
		}
		myStmt.close();
		myRs.close();
		myRs2.close();
		myConn.close();

	} catch (Exception exc) {
		exc.printStackTrace();
	}
%>

<html>
<head>
<%
	out.print(printHtmlObj.printHead("View District"));
%>
</head>

<body>
	<div class="container" id="bbp-content-wrapper">
		<header>
			<%
				String pSessionUsername = String.valueOf(session.getAttribute("sessionUsername"));
				String pSessionPassword = String.valueOf(session.getAttribute("sessionPassword"));
				String pSessionAccountType = String.valueOf(session.getAttribute("sessionAccountType"));
				String pSessionTitle = String.valueOf(session.getAttribute("sessionTitle"));

				if (pSessionAccountType.equals("D")) {
					out.print(printHtmlObj.printNavDistrict(pSessionUsername, pSessionTitle));
				} else if (pSessionAccountType.equals("C")) {
					out.print(printHtmlObj.printNavCitizen(pSessionUsername));
				} else {
					out.print(printHtmlObj.printNavNotLoggedIn());
				}
			%>
		</header>

		<div class="card">
			<div class="card-body">
				<h4 class="card-title">
					<b> <%
							out.print(request.getParameter("title"));
						%> municipal authority
					</b>
				</h4>
				<p></p>
				<p class="card-text mb-3">
					<span class="text-muted">Typically replies in: </span>
					<%
						try {
							String district = getTitle;
							String finalTime = null;
							TypicallyReplies tr = new TypicallyReplies();
							out.print(tr.typical(district));
						} catch (Exception exc) {
							exc.printStackTrace();
							out.print("(not enough data)");
						}
					%>
				</p>
				<p class="card-text mb-3">
					<span class="text-muted">Average Rating: </span>
					<%
						try {
							double finalRating = 0;
							Rating r = new Rating();
							finalRating = r.getAverageRatings(getTitle);
							out.print(finalRating + "/5");
						} catch (Exception exc) {
							exc.printStackTrace();
							out.print("(not enough ratings)");
						}
					%>
				</p>
				<form action="viewDistrict.jsp?title=<%out.print(getTitle);%>">
					<div class="btn-group d-flex justify-content-center">
						<a class="btn btn-primary"
							href="viewDistrict.jsp?title=<%out.print(getTitle);%>&filter=All"
							role="button">All</a> <a class="btn btn-primary"
							href="viewDistrict.jsp?title=<%out.print(getTitle);%>&filter=Resolved"
							role="button">Resolved</a> <a class="btn btn-primary"
							href="viewDistrict.jsp?title=<%out.print(getTitle);%>&filter=Unresolved"
							role="button">Unresolved</a> <a class="btn btn-primary"
							href="viewDistrict.jsp?title=<%out.print(getTitle);%>&filter=Not Replied"
							role="button">Unreplied</a>
					</div>
				</form>

				<table class="table">
					<thead class="thead-light">
						<tr>
							<th scope="col"><a
								href="viewDistrict.jsp?title=<%out.print(getTitle);%>&filter=<% out.print(pFilter); %>&filter2=sub">Subject</a>
							</th>
							<th scope="col"><a
								href="viewDistrict.jsp?title=<%out.print(getTitle);%>&filter=<% out.print(pFilter); %>&filter2=category">Category</a>
							</th>
							<th scope="col"><a
								href="viewDistrict.jsp?title=<%out.print(getTitle);%>&filter=<% out.print(pFilter); %>&filter2=postdate desc">Date
									Sent/Reported</a></th>
						</tr>
					</thead>
					<tbody>
						<%
							for (int i = 0; i < totalListSize; i++) {
						%>
						<tr>
							<td><a
								href="viewConcern.jsp<%out.print("?concernID=" + pConcernID[i]);%>">
									<%
										out.print(pSub[i]);
									%>
							</a></td>
							<td>
								<%
									out.print(pCategory[i]);
								%>
							</td>
							<td>
								<%
									out.print(ldObj[i].getMonth() + " " + ldObj[i].getDayOfMonth() + ", " + ldObj[i].getYear() + " | "
												+ bbpDateObj.addZero(ltObj[i].getHour()) + ":" + bbpDateObj.addZero(ltObj[i].getMinute()));
								%>
							</td>
						</tr>
						<%
							}
						%>
					</tbody>
				</table>

				<h4></h4>
			</div>

		</div>
		<footer id="bbp-footer">
			<hr>
			<p class="mb-0" id="bbp-footer-text">
				<small>BantayBayan Prototype Project. 2017</small>
			</p>
		</footer>
	</div>
	<% out.print(printHtmlObj.printScripts()); %>
</body>
</html>

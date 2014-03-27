<%@ page language="java" contentType="text/html;charset=utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="/tablecloth/tablecloth.css" rel="stylesheet" type="text/css" media="screen" />
<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" type="text/css">
<link rel="stylesheet" href="/css/zTreeStyle/zTreeStyle.css" type="text/css">
<script type="text/javascript" src="http://code.jquery.com/jquery-1.8.3.js"></script>
<script type="text/javascript" src="/js/jquery.ztree.core-3.5.js"></script>
<script type="text/javascript" src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>
</head>

<body>
	<select id="zookeeperAddress">
		<option value="192.168.100.123:2181">192.168.100.123:2181</option>
	</select>

	<select id="category">
	</select>

	<input type="button" id="connectZookeeper" value="连接" />
	<br /> ------------------------------------------------------------------------
	<br />
	<input type="button" id="addDataSource" value="添加数据源" />
	<br />(注意：添加数据源会将数据源模板的数据也一起带过去)

	<table cellspacing="0" cellpadding="0" style="position: absolute">
		<tr>
			<td width=100>
				<div>
					<ul id="datatree" class="ztree"></ul>
				</div>
			</td>
			<td id="nodeData" cellspacing="0" cellpadding="0" style="position: absolute"></td>
		</tr>
	</table>

	<div id="changeDataDialog">
		<input id="hiddenChangeNodeName" type="hidden" /> <label>请填写值</label><br /> <input id="changeNodeValue" type="text" style="width: 50%;" />
	</div>

	<div id="addDataDialog">
		<input id="hiddenNewNodeName" type="hidden" /> <label>请填写节点名称</label><br /> <input id="newNodeName" type="text" style="width: 50%;" /><br /> <label>请填写节点值</label><br /> <input id="newNodeValue"
			type="text" style="width: 50%;" />
	</div>

	<div id="addDataSourceDialog">
		<label>数据源名称</label><br> <input id="dataSourceName" type="text" />
	</div>

	<div id="loginDialog">
		<label>用户名</label><br> <input id="loginusername" type="text" /><br />
		<label>密码</label><br> <input id="loginpassword" type="password" />
	</div>

	<script type="text/javascript">
		var setting = {
			data : {
				key : {
					title : "t"
				},
				simpleData : {
					enable : true
				}
			},
			callback : {
				beforeClick : beforeClick,
				onClick : nodeClick
			}
		};
		
		function loadTree() {
			$.ajax({
				type : "post",
				async : false,
				url : "/test/loadtree",
				dataType : "json",
				cache : false,
				data	: {
					category : $("#category").val()
				},
				error : function() {
					alert("失败");
				},
				success : function(data) {
					$.fn.zTree.init($("#datatree"), setting, data);
					$('#nodeData').empty();
				}
			});
		}

		$("#connectZookeeper").click(function(){
			$.ajax({
				type : "post",
				async : false,
				url : "/test/connectzookeeper",
				dataType : "text",
				cache : false,
				data : {
					zookeeperAddress : $("#zookeeperAddress").val()
				},
				error : function() {
					alert("失败");
				},
				success : function(result) {
					loadTree();
				}
			});
		});

		function nodeClick(event, treeId, treeNode, clickFlag) {
			$.ajax({
				type : "post",
				async : false,
				url : "/test/nodeselect",
				dataType : "json",
				cache : false,
				data : {
					nodeName : treeNode.name
				},
				error : function() {
					alert("失败");
				},
				success : function(data) {
					$('#nodeData').empty();
					$.each(data, function(index, data) {
						var node = data["node"];
						var value = data["value"];
						var category = $("#category").val();
						var html = "<tr><td><input name=\"button\" id=\"add"+node+"\" type=\"button\" value=\"添加子节点\"></td><td><input name=\"button\" id=\"change"+node+"\" type=\"button\" value=\"修改\"></td><td>"+node+"</td><td>"+value+"</td><tr>";							
						$('#nodeData').append(html);
					})
				}
			});
		}

		function beforeClick(treeId, treeNode, clickFlag) {
			return (treeNode.click != false);
		}

		$("input[name=button]").live("click", function() {
			showDataDialog($(this).attr("id"), $(this).val());
		})

		function showDataDialog(nodeName, op) {
			if (op == "修改") {
				var category = $("#category").val();
				if (category == "/ds") {
					var length = nodeName.split("/").length;
					if (length == 3) {//点击的是business节点
						alert("检测到正在修改business节点状态！请注意，如果子节点（服务器节点）还有\"-1\"的情况，请确认已经修改为大于0的任何值或者确实不需要修改，再修改此节点");
					}
					else if (length == 4) {//点击的是服务器节点
						alert("检测到正在修改服务器节点状态！请注意，在修改服务器节点状态的时候，每次修改成不一样的值，框架才会刷新");					
					}					
				}
				$("#changeDataDialog").dialog("open");
				$("#hiddenChangeNodeName").val(nodeName);
				$("#changeDataDialog").dialog({
					width : 550
				});				
			}

			if (op == "添加子节点") {
				$("#addDataDialog").dialog("open");
				$("#hiddenNewNodeName").val(nodeName);
				$("#addDataDialog").dialog({
					width : 550
				});				
			}
		}		
		
		function updateData() {
			$.ajax({
				type : "post",
				async : false,
				url : "/test/updatedata",
				dataType : "text",
				cache : false,
				data : {
					nodeName : $("#hiddenChangeNodeName").val(),
					nodeData : $("#changeNodeValue").val()
				},
				error : function() {
					alert("失败");
				},
				success : function(ok) {
					$("#changeNodeValue").val("");
					$("#changeDataDialog").dialog("close");
					alert("完成，请再次点击节点查看数据");
				}
			});
		}

		function insertData() {
			$.ajax({
				type : "post",
				async : false,
				url : "/test/adddata",
				dataType : "text",
				cache : false,
				data : {
					nodeName : $("#hiddenNewNodeName").val(),
					newNodeName : $("#newNodeName").val(),
					newNodeData : $("#newNodeValue").val()
				},
				error : function() {
					alert("失败");
				},
				success : function(ok) {
					$("#newNodeName").val("");
					$("#newNodeValue").val("");
					$("#addDataDialog").dialog("close");
					loadTree();
				}
			});
		}

		$("#addDataSource").click(function(){
			var category = $("#category").val();
			if (category != "/ds")	{
				alert("["+category+"]暂不支持");
				return ;
			}

			$("#addDataSourceDialog").dialog("open");
		});		
		
		function addDataSource() {
			$.ajax({
				type : "post",
				async : false,
				url : "/test/adddatasource",
				dataType : "text",
				cache : false,
				data : {
					rootNodeName : $("#category").val(),
					dataSourceName : $("#dataSourceName").val()
				},
				error : function() {
					alert("失败");
				},
				success : function(ok) {
					$("#addDataSourceDialog").dialog("close");
					loadTree();
				}
			});
		}
		
		function login() {
			$.ajax({
				type : "post",
				async : false,
				url : "/test/login",
				dataType : "json",
				cache : false,
				data : {
					username : $("#loginusername").val(),
					password : $("#loginpassword").val()
				},
				error : function() {
					alert("失败");
				},
				success : function(result) {
					if (result == null) {
						alert("未匹配到有效用户，请查看WEB-INF/dispatcher-servlet.xml里面的用户配置");
					}
					else {
						$("#loginDialog").dialog("close");
						$.each(result, function(index, result) {
							$("#category").append("<option value=\""+result["path"]+"\">"+result["path"]+"</option>");
						})
					}
				}
			});
		}

		$(document).ready(function() {
			$.ajax({
				type : "post",
				async : false,
				url : "/test/closezookeeper",
				dataType : "json",
				cache : false,
				error : function() {
				},
				success : function(result) {
				}
			});

			$("#changeDataDialog").dialog({
				title : "修改节点数据",
				modal : true,
				autoOpen : false,
				resizable : false,
				buttons : {
					"修改" : function() {
						updateData();
					},
					"关闭" : function() {
						$(this).dialog("close");
					}
				}
			});
			
			$("#addDataDialog").dialog({
				title : "添加节点",
				modal : true,
				autoOpen : false,
				resizable : false,
				buttons : {
					"添加" : function() {
						insertData();
					},
					"关闭" : function() {
						$(this).dialog("close");
					}
				}
			});

			$("#loginDialog").dialog({
				title : "登录",
				modal : true,
				autoOpen : false,
				resizable : false,
				closeOnEscape : false,
				buttons : {
					"登录" : function() {
						login();
					}
				}
			});

			$("#addDataSourceDialog").dialog({
				title : "添加数据源",
				modal : true,
				autoOpen : false,
				resizable : false,
				buttons : {
					"添加" : function() {
						addDataSource();
					},
					"关闭" : function() {
						$(this).dialog("close");
					}
				}
			});
			
			$(".ui-dialog-titlebar-close").hide();
			$("#loginDialog").dialog("open");
		});
	</script>
</body>
</html>
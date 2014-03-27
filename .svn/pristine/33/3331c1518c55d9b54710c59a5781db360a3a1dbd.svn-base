package koolearn.framework.zookeeperassist.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.ZooKeeper;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;

public class ZookeeperManagement implements InitializingBean, DisposableBean
{
	private ZooKeeper zooKeeper = null;
	private String json = "";
	public String getJson()
	{
		return this.json;
	}
	public void setJson(String json)
	{
		this.json = json;
	}
	public void afterPropertiesSet() throws Exception
	{
	}
	public String getData(String path) throws Exception
	{
		if (this.zooKeeper != null)
		{
			try
			{
				return new String(this.zooKeeper.getData(path, false, null));
			}
			catch (Exception e)
			{
			}
		}
		return "";
	}
	public List<String> getChildren(String path) throws Exception
	{
		if (this.zooKeeper != null)
		{
			try
			{
				return this.zooKeeper.getChildren(path, false);
			}
			catch (Exception e)
			{
			}
		}
		return new ArrayList<String>();
	}
	public void setData(String path, String data) throws Exception
	{
		if (this.zooKeeper != null)
		{
			try
			{
				this.zooKeeper.setData(path, data.getBytes(), -1);
			}
			catch (Exception e)
			{
			}
		}
	}
	public void destroy() throws Exception
	{
		if (this.zooKeeper != null)
		{
			this.zooKeeper.close();
		}
	}
	public void getJson(String currentPath, UUID currentId, UUID parentId, boolean isRoot) throws Exception
	{
		if (this.zooKeeper == null)
		{
			return;
		}
		List<String> pathList = null;
		if (isRoot)
		{
			this.json += "{\"id\":\"" + currentId + "\",\"pId\":\"" + parentId + "\",\"name\":\"" + currentPath + "\",\"t\":\"" + currentPath + "\",\"open\":\"true\"},";
		}
		else
		{
			this.json += "{\"id\":\"" + currentId + "\",\"pId\":\"" + parentId + "\",\"name\":\"" + currentPath + "\",\"t\":\"" + currentPath + "\",\"open\":\"false\"},";
		}
		pathList = this.zooKeeper.getChildren(currentPath, false);
		for (String item : pathList)
		{
			this.getJson(currentPath + "/" + item, UUID.randomUUID(), currentId, false);
		}
	}
	public void addDataSource(String currentPath, String dataSourceName, boolean isRoot) throws Exception
	{
		if (this.zooKeeper == null)
		{
			return;
		}
		int index = currentPath.indexOf("/", 1);
		String begin = currentPath.substring(0, index);
		index = currentPath.indexOf("/", index + 1);
		String end = "";
		if (index > 0)
		{
			end = currentPath.substring(index, currentPath.length());
		}
		String path = begin + "/" + dataSourceName + end;
		String data = this.getData(currentPath);
		this.zooKeeper.create(path, data.getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
		List<String> pathList = this.zooKeeper.getChildren(currentPath, false);
		for (String item : pathList)
		{
			this.addDataSource(currentPath + "/" + item, dataSourceName, false);
		}
	}
	public boolean open(String zookeeperAddress) throws Exception
	{
		if (this.zooKeeper != null)
		{
			this.zooKeeper.close();
			this.zooKeeper = null;
		}
		this.zooKeeper = new ZooKeeper(zookeeperAddress, 500000, new MyWatcher());
		if (this.zooKeeper == null)
		{
			return false;
		}
		return true;
	}
	public void close() throws Exception
	{
		if (this.zooKeeper != null)
		{
			this.zooKeeper.close();
			this.zooKeeper = null;
		}
	}
	public void createData(String newNodeName, String newNodeData) throws Exception
	{
		if (this.zooKeeper == null)
		{
			return;
		}
		try
		{
			this.zooKeeper.create(newNodeName, newNodeData.getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
		}
		catch (Exception e)
		{
		}
	}
}

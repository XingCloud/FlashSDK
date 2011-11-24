package com.xingcloud.model.item.spec
{
	import com.xingcloud.core.Config;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.net.connector.Connector;
	import com.xingcloud.net.connector.FileConnector;
	import com.xingcloud.services.StatusManager;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.tasks.TaskEvent;
	import com.xingcloud.util.Debug;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	import com.xingcloud.core.xingcloud_internal;
	use namespace xingcloud_internal;
	/**
	 *物品服务加载完毕后派发
	 */
	[Event(type="flash.events.Event", name="complete")]
	/**
	 *物品服务加载进度
	 */
	[Event(type="flash.events.ProgressEvent", name="progress")]
	/**
	 *物品定义管理器，用于物品定义文件的加载和调度，通过各种标示来查找相应物品的定义。
	 *
	 */
	public class ItemSpecManager extends EventDispatcher
	{
		private static var _instance:ItemSpecManager;

		/**
		 *获取物品定义管理器的唯一实例
		 *
		 */
		public static function get instance():ItemSpecManager
		{
			if (_instance == null)
				_instance=new ItemSpecManager(new SingleLock());
			return _instance;
		}

		public function ItemSpecManager(lock:SingleLock)
		{
			super();
		}

		private var _source:XML;
		private var _groups:Dictionary=new Dictionary();

		/**
		 *增加一个物品定义组
		 * @param group
		 *
		 */
		public function addGroup(group:ItemGroup):void
		{
			_groups[group.id]=group;
		}

		/**
		 * 整个库文件的xml定义
		 * */
		public function get source():XML
		{
			return _source;
		}

		public function set source(d:XML):void
		{
			_source=d;
		}


		/**
		 * 获取一组name为_name的物品，name属性对所有item来说是可以重复的
		 * */
		public function getItemsByName(_name:String, _groupId:String="all", _groupType:String=null):Array
		{
			var groups:Array=this.getGroups(_groupId, _groupType);
			var itms:Array=[];
			for each (var group:ItemGroup in groups)
			{
				var itm:ItemSpec=group.getItemByName(_name, true);

				if (itm)
					itms.push(itm);
			}
			return itms;
		}

		/**
		 * 获取group组
		 * */
		public function getGroups(_id:String=null, _type:String=null):Array
		{
			var groups:Array=[];
			if (_id != null)
			{
				groups[0]=this._groups[_id];
			}
			else
			{
				for each (var group:ItemGroup in _groups)
				{
					if (_type != null)
					{
						if (group.type == _type)
							groups.push(group);
					}
					else
					{
						groups.push(group);
					}
				}
			}
			return groups;
		}

		/**
		 *通过条件查询itemspec
		 * @param _id
		 * @param _groupId
		 * @param _groupType
		 * @return
		 *
		 */
		public function getItem(_id:String, _groupId:String=null, _groupType:String=null):ItemSpec
		{
			var groups:Array=this.getGroups(_groupId, _groupType);
			for each (var group:ItemGroup in groups)
			{
				var itm:ItemSpec=group.getItem(_id);
				if (itm != null)
					return itm;
			}
			return null;
		}

		/**
		 *获取特定的物品定义组
		 * @param _id
		 * @param deepSearch
		 * @return
		 *
		 */
		public function getGroup(_id:String, deepSearch:Boolean=true):ItemGroup
		{
			if (!deepSearch)
				return this._groups[_id];
			for each (var g:ItemGroup in this._groups)
			{
				if (g.id == _id)
					return g;
				var rg:ItemGroup=g.getChildGroup(_id);
				if (rg)
					return rg;
			}
			return null;
		}

		/**
		 *获得某定义组内元素
		 * @param _groupId
		 * @return
		 *
		 */
		public function getItemsInGroup(_groupId:String):Array
		{
			var group:ItemGroup=this.getGroup(_groupId);
			return group.getAllItems(true);
		}

		/**
		 *加载物品定义，并在加载成功后派发<code>Event.COMPLETE</code>事件
		 *
		 */
		public function load():void
		{
			createTask().execute();
		}

		/**
		 *为物品定义加载创建一个任务，以便和其他任务共同执行。任务执行完毕后会自动处理相关文件。
		 * @return 物品服务任务
		 *
		 */
		public function createTask():Task
		{
			var connector:Connector=new FileConnector(Config.fileGateway,
				Config.ITEMSDB_SERVICE,
				{lang: Config.languageType, timestamp: StatusManager.getStatus(Config.ITEMSDB_SERVICE)},
				URLRequestMethod.POST,
				XingCloud.needAuth,
				URLLoaderDataFormat.TEXT);
			connector.addEventListener(TaskEvent.TASK_COMPLETE, onItemComplete);
			connector.addEventListener(TaskEvent.TASK_PROGRESS, onProgress);
			connector.addEventListener(TaskEvent.TASK_ERROR, onItemError);
			return connector;
		}

		private function onItemComplete(event:TaskEvent):void
		{
			try
			{
				ItemsParser.parse(new XML((event.target).data.data as String));
			}
			catch (e:Error)
			{
				Debug.error("Can not parse Item file.", this);
			}
			dispatchEvent(new Event(Event.COMPLETE));

		}

		private function onProgress(event:TaskEvent):void
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,
				false,
				false,
				event.task.completeNum,
				event.task.totalNum));
		}

		private function onItemError(event:TaskEvent):void
		{
			Debug.error("Item Service request error.", this);
		}
	}
}

class SingleLock
{
}

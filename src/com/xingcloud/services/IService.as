package com.xingcloud.services
{
	import com.xingcloud.tasks.Task;

	public interface IService
	{
		function get executor():Task;
	}
}

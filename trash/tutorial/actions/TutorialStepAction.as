package com.elex.tutorial.actions
{
	import com.elex.users.actions.Action;
	
	public class TutorialStepAction extends Action
	{
		public function TutorialStepAction(tutorial:String,name:String,step:uint)
		{
			super({XA_tutorial:tutorial,XA_name:name,XA_index:step});
		}
	}
}
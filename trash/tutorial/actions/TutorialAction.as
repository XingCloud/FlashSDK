package  com.elex.tutorial.actions
{
	import com.elex.users.actions.Action;
	
	public class TutorialAction extends Action
	{
		public function TutorialAction(name:String)
		{
			super({XA_tutorial:name,XA_state:"over"});
		}
	}
}
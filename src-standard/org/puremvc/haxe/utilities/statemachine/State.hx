/*
  PureMVC haXe Utility - StateMachine Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
  Copyright (c) 2008 Neil Manuell, Cliff Hall
  Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.puremvc.haxe.utilities.statemachine;

/**
 * Defines a State.
 */
class State
{
	// The state name
	public var name : String;
	
	// The notification to dispatch when entering the state
	public var entering : String;
	
	// The notification to dispatch when exiting the state
	public var exiting : String;
	
	// The notification to dispatch when the state has actually changed
	public var changed : String;

	/**
	 * Constructor.
	 */
	public function new( name : String, ?entering : String = null, 
		?exiting : String = null, ?changed : String = null )
	{
		this.name = name;
		if( entering != null ) this.entering = entering;
		if( exiting != null ) this.exiting = exiting;
		if( changed != null ) this.changed = changed;
		transitions = new Hash<String>();
	}
	
	/** 
	 * Define a transition. 
	 */
	public function defineTrans( action : String, target : String ) : Void
	{
		if( getTarget( action ) != null ) return;	
		transitions.set( action, target );
	}

	/** 
	 * Remove a previously defined transition.
	 */
	public function removeTrans( action : String ) : Void
	{
		transitions.remove( action );	
	}	
	
	/**
	 * Get the target state name for a given action.
	 */
	public function getTarget( action : String ) : String
	{
		return transitions.get( action );
	}
	
	/**
	 *  Transition map of actions to target states
	 */ 
	private var transitions : Hash<String>;
	
}

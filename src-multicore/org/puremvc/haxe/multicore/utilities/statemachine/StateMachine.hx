/*
  PureMVC haXe Utility - StateMachine Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
  Copyright (c) 2008 Neil Manuell, Cliff Hall
  Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.puremvc.haxe.multicore.utilities.statemachine;

import org.puremvc.haxe.multicore.interfaces.INotification;
import org.puremvc.haxe.multicore.patterns.mediator.Mediator;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>;
#end

/**
 * A Finite State Machine implementation.
 * 
 * <p>Handles regisistration and removal of state definitions, 
 * which include optional entry and exit commands for each 
 * state.</p>
 */
class StateMachine extends Mediator
{
	
	public static inline var NAME : String = "StateMachine";

	/**
	 * Action Notification name. 
	 */ 
	public static inline var ACTION : String = NAME + "/notes/action";

	/**
	 *  Changed Notification name  
	 */ 
	public static inline var CHANGED : String = NAME + "/notes/changed";
	
	/**
	 *  Cancel Notification name  
	 */ 
	public static inline var CANCEL : String = NAME + "/notes/cancel";
	
	/**
	 * Constructor.
	 */
	public function new()
	{
		super( NAME );
		states = new StringMap<State>();
	}
	
	override public function onRegister() : Void
	{
		if( initial != null ) transitionTo( initial );	
	}
	
	/**
	 * Registers the entry and exit commands for a given state.
	 */
	public function registerState( state : State, ?initial : Bool = false ) : Void
	{
		if( state == null || states.exists( state.name ) ) return;
		states.set( state.name, state );
		if( initial ) this.initial = state; 
	}
	
	/**
	 * Remove a state mapping.
	 * 
	 * <p>Removes the entry and exit commands for a given state 
	 * as well as the state mapping itself.</p>
	 */
	public function removeState( stateName : String ) : Void
	{
		if( states.exists( stateName ) )
			states.remove( stateName );
	}
	
	/**
	 * Transitions to the given state from the current state.
	 * <p>
	 * Sends the [exiting] notification for the current state 
	 * followed by the [entering] notification for the new state.
	 * Once finally transitioned to the new state, the [changed] 
	 * notification for the new state is sent.</p>
	 * <p>
	 * If a data parameter is provided, it is included as the body of all
	 * three state-specific transition notes.</p>
	 * <p>
	 * Finally, when all the state-specific transition notes have been
	 * sent, a [StateMachine.CHANGED] note is sent, with the
	 * new [State] object as the [body] and the name of the 
	 * new state in the [type].</p>
	 */
	private function transitionTo( nextState : State, ?data : Dynamic = null ) : Void
	{
		// Going nowhere?
		if( nextState == null ) return;
		
		// Clear the cancel flag
		canceled = false;
			
		// Exit the current State
		if( currentState != null && currentState.exiting != null )
			sendNotification( currentState.exiting, data, nextState.name );
		
		// Check to see whether the exiting guard has been canceled
		if( canceled ) {
			canceled = false;
			return;
		}
		
		// Enter the next State 
		if( nextState.entering != null ) sendNotification( nextState.entering, data );
			
		// Check to see whether the entering guard has been canceled
		if( canceled ) {
			canceled = false;
			return;
		}
		
		// change the current state only when both guards have been passed
		currentState = nextState;
		
		// Send the notification configured to be sent when this specific state becomes current 
		if( nextState.changed != null ) sendNotification( currentState.changed, data );

		// Notify the app generally that the state changed and what the new state is 
		sendNotification( CHANGED, currentState, currentState.name );
	}
	
	/**
	 * Notification interests for the StateMachine.
	 */
	override public function listNotificationInterests() : Array<String>
	{
		return [ 	ACTION,
					CANCEL	];
	}
	
	/**
	 * Handle notifications the [StateMachine] is interested in.
	 *
	 * <p>[StateMachine.ACTION]: Triggers the transition to a new state.</p>
	 *
	 * <p>[StateMachine.CANCEL]: Cancels the transition if sent in response to the exiting note for the current state.</p>
	 */
	override public function handleNotification( note : INotification ) : Void
	{
		var name = note.getName();
		
		if (name == ACTION)
		{
			var action : String = note.getType();
			var target : String = currentState.getTarget( action );
			if( states.exists( target ) )
				transitionTo( states.get( target ), note.getBody() );
		}
		else if (name == CANCEL)
		{
			canceled = true;
		}
	}
	
	#if haxe3
	public var currentState( get, set ) : State;
	#else
	public var currentState( get_currentState, set_currentState ) : State;
	#end
	
	/**
	 * Get the current state.
	 */
	private function getCurrentState() : State
	{
		return get_currentState();
	}
	
	private function get_currentState() : State
	{
		return viewComponent;
	}
	
	/**
	 * Set the current state.
	 */
	private function setCurrentState( state : State ) : State
	{
		return set_currentState( state );
	}
	
	private function set_currentState( state : State ) : State
	{
		viewComponent = state;
		return state;
	}
	
	/**
	 * Map of States objects by name.
	 */
	private var states : StringMap<State>;
	
	/**
	 * The initial state of the FSM.
	 */
	private var initial : State;
	
	/**
	 * The transition has been canceled.
	 */
	private var canceled : Bool;

}

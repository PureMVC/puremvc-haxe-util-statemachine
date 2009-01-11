/*
  PureMVC haXe Utility - StateMachine Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
  Copyright (c) 2008 Neil Manuell, Cliff Hall
  Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.puremvc.haxe.utilities.statemachine;

import org.puremvc.haxe.interfaces.INotification;
import org.puremvc.haxe.patterns.mediator.Mediator;

/**
 * A Finite State Machine implimentation.
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
		states = new Hash<State>();
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
	 *
	 * <p>Sends the exiting notification for the current state 
	 * and the entering notification for the new state.</p>
	 *
	 * <p>Both the exiting notification for the current state
	 * and the entering notification for the next state
	 * will have a reference to the next state in the note
	 * body.</p>
	 */
	private function transitionTo( nextState : State ) : Void
	{
		// Going nowhere?
		if( nextState == null ) return;
		
		// Clear the cancel flag
		canceled = false;
			
		// Exit the current State (if set)
		if( currentState != null ) {
			if( nextState.name == currentState.name ) return;
			if( currentState.exiting != null ) sendNotification( currentState.exiting, nextState );
		}
		
		// Check to see whether the transition has been canceled
		if( canceled ) {
			canceled = false;
			return;
		}
		
		// Enter the next State 
		if( nextState.entering != null ) sendNotification( nextState.entering, nextState );
		currentState = nextState;
		
		// Notify the app that the state changed and what the new state is 
		sendNotification( CHANGED, currentState );
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
		switch( note.getName() )
		{
			case ACTION:
				var action : String = note.getType();
				var target : String = currentState.getTarget( action );
				if( states.exists( target ) )
					transitionTo( states.get( target ) );
			case CANCEL:
				canceled = true;
		}
	}
	
	public var currentState( getCurrentState, setCurrentState ) : State;
	
	/**
	 * Get the current state.
	 */
	private function getCurrentState() : State
	{
		return viewComponent;
	}
	
	/**
	 * Set the current state.
	 */
	private function setCurrentState( state : State ) : State
	{
		viewComponent = state;
		return state;
	}
	
	/**
	 * Map of States objects by name.
	 */
	private var states : Hash<State>;
	
	/**
	 * The initial state of the FSM.
	 */
	private var initial : State;
	
	/**
	 * The transition has been canceled.
	 */
	private var canceled : Bool;

}

/*
  PureMVC haXe Utility - StateMachine Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
  Copyright (c) 2008 Neil Manuell, Cliff Hall
  Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.puremvc.haxe.multicore.utilities.statemachine;

import org.puremvc.haxe.multicore.patterns.observer.Notifier;

/**
 * Creates and registers a StateMachine described in Xml.
 * 
 * <p>This allows reconfiguration of the StateMachine 
 * without changing any code, as well as making it 
 * easier than creating all the [State] 
 * instances and registering them with the 
 * [StateMachine] at startup time.</p>
 */
class FSMInjector extends Notifier
{
	/**
	 * Constructor.
	 */
	public function new( fsm : Xml ) 
	{
		super();
		this.fsm = fsm;
	}
	
	/**
	 * Inject the [StateMachine] into the PureMVC apparatus.
	 * 
	 * <p>Creates the [StateMachine] instance, registers all the states
	 * and registers the [StateMachine] with the [IFacade].</p>
	 */
	public function inject() : Void
	{
		// Create the StateMachine
		var stateMachine = new StateMachine();
		
		// Register all the states with the StateMachine
		for( state in states )
		{ 
			stateMachine.registerState( state, isInitial( state.name ) );
		}
		
		// Register the StateMachine with the facade
		facade.registerMediator( stateMachine );
	}

	
	/**
	 * Get the state definitions.
	 *
	 * <p>Creates and returns the array of State objects 
	 * from the FSM on first call, subsequently returns
	 * the existing array.</p>
	 */
	private function getStates() : List<State>
	{
		return get_states();
	}
	
	private function get_states() : List<State>
	{
		if( stateList == null ) {
			stateList = new List();
			for( stateDef in fsm.elementsNamed("state") )
			{
				var state : State = createState( stateDef );
				stateList.add( state );
			}
		}
		return stateList;
	}
	
	#if haxe3
	public var states( get, null ) : List<State>;
	#else
	public var states( get_states, null ) : List<State>;
	#end

	/**
	 * Creates a [State] instance from its Xml definition.
	 */
	private function createState( stateDef : Xml ) : State
	{
		// Create State object
		var name = stateDef.get("name");
		var exiting = stateDef.get("exiting");
		var entering = stateDef.get("entering");
		var changed = stateDef.get("changed");
		var state = new State( name, entering, exiting, changed );
		
		// Create transitions
		for( transDef in stateDef.elementsNamed("transition") )
		{
			state.defineTrans( transDef.get("action"), transDef.get("target") );
		}
		return state;
	}

	/**
	 * Is the given state the initial state?
	 */
	private function isInitial( stateName : String ) : Bool
	{
		var initial = fsm.get("initial");
		return (stateName == initial);
	}
	
	// The Xml FSM definition
	private var fsm : Xml;
	
	// The List of State objects
	private var stateList : List<State>;
	
}

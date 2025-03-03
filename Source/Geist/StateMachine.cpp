#include "StateMachine.h"
#include "Logging.h"

using namespace std;

void StateMachine::Init(const std::string& configfile) {
    Log("Starting StateMachine::Init");
    m_StateStack.clear();
    Log("Leaving StateMachine::Init");
}

void StateMachine::Shutdown() {
    //  Unroll the current state stack, calling the OnExit() of each state:
    for (auto i = m_StateStack.begin(); i != m_StateStack.end(); ++i) {
        m_StateMap[get<0>(*i)]->OnExit();
    }

    //  Shutdown all existing states
    for (map<int, State*>::iterator node = m_StateMap.begin();
         node != m_StateMap.end(); ++node) {
        node->second->Shutdown();
        delete node->second;
    }
}

void StateMachine::Update() {
    //  Run any transition commands to properly change states.
    while (m_TransitionStack.size() > 0) {
        switch (get<0>(
            m_TransitionStack[0]))  //  What kind of transition are we making?
        {
        case TT_STATE:
            MakeStateTransitionEX(get<1>(m_TransitionStack[0]));
            break;

        case TT_PUSH:
            PushStateEX(get<1>(m_TransitionStack[0]));
            break;

        case TT_POP:
            PopStateEX();
            break;
        }
        m_TransitionStack.pop_front();
    }

    m_StateMap[get<0>(m_StateStack[0])]->Update();
}

void StateMachine::Draw() {
    //  We draw states in reverse order, so popups are drawn on top of the
    //  states they are popped on top of.

    for (auto i = m_StateStack.rbegin(); i != m_StateStack.rend(); ++i) {
        m_StateMap[get<0>(*i)]->Draw();
    }
}

void StateMachine::RegisterState(int id, State* state, string name) {
    if (m_StateMap.find(id) == m_StateMap.end()) {
        m_StateMap[id] = state;
        m_StateNames[id] = name;
        Log("Created state " + name + " with ID " + to_string(id));
    } else {
        throw("StateMachine: Attempt to register state using duplicate state "
              "identifier " +
              to_string(id));
    }
}

void StateMachine::MakeStateTransition(int newstate) {
    m_TransitionStack.push_back(make_tuple(TT_STATE, newstate));
    Log("StateMachine: Transitioning to state " + m_StateNames[newstate] +
        ", ID " + to_string(newstate));
}

void StateMachine::MakeStateTransitionEX(int newstate) {
    if (m_StateStack.size() > 0 && get<1>(m_StateStack[0]) != ST_STATE) {
        //  The top state is a push state, we can't transition from it.
        throw("StateMachine: Attempting to transition from a pushed state!  "
              "Current state ID: " +
              to_string(get<0>(m_StateStack[0])) +
              " Incoming state ID: " + to_string(newstate));
    }

    if (m_StateMap.find(newstate) == m_StateMap.end()) {
        //  Um...trying to transition to a state that doesn't exist.
        throw("StateMachine: Bad state identifier: " + to_string(newstate));
    }

    m_PreviousState = m_CurrentState;
    m_CurrentState = newstate;

    //  Handle exiting the previous state
    if (m_StateStack.size() > 0) {
        m_StateMap[get<0>(m_StateStack[0])]->OnExit();
        m_StateStack.pop_front();
    }

    m_StateStack.push_front(make_tuple(newstate, ST_STATE));
    m_StateMap[get<0>(m_StateStack[0])]->OnEnter();
}

void StateMachine::PushState(int newstate) {
    m_TransitionStack.push_back(make_tuple(TT_PUSH, newstate));
}

void StateMachine::PushStateEX(int newstate) {
    if (m_StateMap.find(newstate) !=
        m_StateMap.end())  //  Does the new state exist in the state map?
    {
        m_PreviousState = m_CurrentState;
        m_CurrentState = newstate;
        m_StateStack.push_front(make_tuple(newstate, ST_PUSHSTATE));
        m_StateMap[newstate]->OnEnter();
    } else {
        throw("StateMachine: Bad state identifier: " + to_string(newstate));
    }
}

void StateMachine::PopState() {
    m_TransitionStack.push_back(make_tuple(TT_POP, -1));
}

void StateMachine::PopStateEX() {
    if (m_StateStack.size() >
        0)  // Is there at least one state in the state stack?
    {
        if (get<1>(m_StateStack[0]) ==
            ST_PUSHSTATE)  //  Make sure we're popping a pushed state.
        {
            m_PreviousState = m_CurrentState;
            m_StateMap[get<0>(m_StateStack[0])]
                ->OnExit();  // Run the OnExit of the state we're popping.
            m_StateStack.pop_front();
            m_CurrentState = get<0>(m_StateStack[0]);
        } else {
            throw("StateMachine: Attempting to pop a state that wasn't pushed! "
                  " State ID: " +
                  to_string(get<0>(m_StateStack[0])));
        }
    }
}

State* StateMachine::GetState(int identifier) {
    if (m_StateMap.size() > 0) {
        if (m_StateMap.find(identifier) != m_StateMap.end()) {
            return m_StateMap[identifier];
        } else {
            throw("Bad state identifier in StateMachine!");
        }
    } else {
        throw("Bad state identifier in StateMachine!");
    }
}

int StateMachine::GetPreviousState() { return m_PreviousState; }

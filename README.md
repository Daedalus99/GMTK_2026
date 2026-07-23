# GMTK 2026 Incremental Game Foundation

A lightweight, reusable foundation for incremental/idle games built with Godot 4.7, using Maaack's Menus Template for UI infrastructure.

## Architecture Overview

The game follows a modular architecture with clear separation between state, systems, and presentation:

- **Core Systems**: `RunState` manages the central game loop, target reduction, and win/loss conditions. `ActionManager` handles action economics, automation, and player upgrades.
- **Data-Driven Configuration**: `ScenarioResource` and `ActionResource` define game parameters without hardcoded values.
- **UI Layer**: Responsive Control-based UI that displays state and issues commands to systems.
- **Fixed-Tick Simulation**: 10 Hz simulation for deterministic, browser-friendly performance.

### Key Components

```
game/
├── core/                   # Core game systems
│   ├── run_state.gd       # Central run state management
│   └── action_manager.gd   # Action economics and automation
├── data/                   # Resource type definitions
│   ├── scenario_resource.gd
│   └── action_resource.gd
├── resources/              # Game configuration files
│   ├── scenarios/
│   └── actions/
├── utilities/              # Helper functions
│   └── number_formatter.gd
├── ui/                     # User interface
│   ├── game_ui.gd/.tscn   # Main game interface
│   └── action_row.gd/.tscn # Individual action display
└── scenes/
    └── prototype_game.tscn # Main game scene
```

## Getting Started

### Launching the Game

1. Open the project in Godot 4.7
2. The main menu will appear (provided by Maaack's template)
3. Click "Start Game" to launch the prototype
4. Use actions to reduce the target value to zero before time runs out

### Basic Gameplay

- **Objective**: Reduce the large target number to exactly zero
- **Manual Actions**: Click "Use" buttons to manually reduce the target
- **Automation**: Purchase action levels and enable automation with checkboxes
- **Economy**: Earn credits to purchase upgrades and new action levels
- **Progression**: New actions unlock at specific progress thresholds (25%, 50%, 75%)
- **Win Condition**: Target reaches zero
- **Loss Condition**: Timer reaches zero while target is above zero

## Customization

### Creating a New Scenario

1. Create a new `ScenarioResource` in `game/resources/scenarios/`
2. Set the parameters:
   - `scenario_id`: Unique identifier
   - `display_name`: Name shown in UI
   - `starting_target`: Initial value to reduce
   - `has_timer`: Enable/disable time pressure
   - `run_duration`: Time limit in seconds
   - `progress_thresholds`: Array of 0-1 values for unlock points
3. Update `prototype_game.gd` to reference the new scenario

### Creating a New Action

1. Create a new `ActionResource` in `game/resources/actions/`
2. Configure the parameters:
   - `action_id`: Unique identifier
   - `display_name` / `description`: UI text
   - `base_purchase_cost`: Initial cost
   - `cost_scaling_factor`: Cost multiplier per level (e.g., 1.5 = 50% increase)
   - `base_manual_reduction`: Manual click output
   - `base_auto_reduction_rate`: Automated output per second
   - `output_scaling_factor`: Output multiplier per level
   - `cooldown_duration`: Seconds between manual uses
   - `max_level`: Maximum levels (-1 = unlimited)
   - `unlock_threshold`: Progress ratio (0-1) to unlock
   - `starts_unlocked`: Available from game start
3. Add the action to the `action_resources` array in `prototype_game.gd`

### Tuning Values

- **Economy**: Starting credits and credit rewards are in `action_manager.gd`
- **Simulation Frequency**: Modify `SIMULATION_TICK_RATE` constants in core systems
- **Number Display**: Update thresholds in `NumberFormatter.format_number()`
- **UI Layout**: Modify `.tscn` files for visual arrangement

### Applying a Theme

The current implementation uses neutral terminology and default Godot UI styling:

1. **Replace Terminology**: Update `display_name` and `description` in all resources
2. **Visual Styling**: Create a custom Theme resource and apply to UI scenes
3. **Audio**: Integrate with Maaack's audio controllers for themed sounds
4. **Background/Effects**: Add visual elements to scene backgrounds
5. **Win/Loss Messages**: Update overlay text in `game_ui.tscn`

## Theme Integration Examples

The foundation supports these game concepts:

### Cyberpunk City Evacuation
- Target: Population remaining in blast zone
- Actions: "Deploy Transport", "Override Security", "Emergency Broadcast"
- Credits become "Authority Points" or "Resources"
- Timer represents countdown to explosion

### Corporate Liquidation
- Target: Remaining corporate value
- Actions: "Sell Assets", "Fire Staff", "Legal Maneuvers"  
- Credits become "Liquidity" or "Influence"
- Timer represents hostile takeover deadline

### Biological Conversion
- Target: Biological matter remaining
- Actions: "Nano Assembly", "Organic Breakdown", "System Override"
- Credits become "Processing Power" or "Energy"
- Timer represents conversion deadline

## Technical Notes

### Web Export Compatibility
- Uses Compatibility renderer (required)
- Fixed-tick simulation reduces browser performance issues
- No threads, native plugins, or filesystem dependencies
- Numbers formatted to avoid precision display problems

### Maaack's Integration
- Pause menu: Press ESC during gameplay
- Scene loading: Handled automatically by SceneLoader
- Audio: ProjectMusicController manages background music
- Settings: Options menu available from main menu

### Performance Considerations
- 10 Hz simulation tick prevents excessive calculations
- UI updates only when display values change significantly
- Action cooldowns processed separately from main simulation
- ScrollContainer handles large numbers of actions efficiently

## File Organization

### Configuration Files (Modify these to change game behavior)
- `game/resources/scenarios/`: Scenario definitions
- `game/resources/actions/`: Action definitions
- `game/app_config.tscn`: Scene path configuration

### Core Logic (Edit carefully)
- `game/core/run_state.gd`: Win/loss conditions, timer logic
- `game/core/action_manager.gd`: Economic calculations, automation
- `game/utilities/number_formatter.gd`: Display formatting

### UI Implementation (Modify for visual changes)
- `game/ui/game_ui.tscn`: Main layout and styling
- `game/ui/action_row.tscn`: Individual action appearance

## Development Next Steps

This foundation provides the core loop for incremental games. Potential additions:

- **Prestige System**: Reset progress for permanent bonuses
- **Events**: Random events that affect progression
- **Multiple Resources**: Additional currencies beyond credits
- **Save System**: Progress persistence between sessions
- **Achievements**: Goal tracking and rewards
- **Balancing Tools**: Runtime parameter adjustment for tuning
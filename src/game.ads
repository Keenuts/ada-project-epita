with Entity; use Entity;
with Renderer; use Renderer;
with Ada.Real_Time; use Ada.Real_Time; -- for seconds

package Game is
	MAX_ENEMY_COUNT : constant CellId := 7;
	type EnemiesArray is array(CellId range 1 .. MAX_ENEMY_COUNT) of Enemy;

	MAX_PARTICLE_COUNT : constant Natural := 10;
	type ParticleArray is array(Natural range 1 .. MAX_PARTICLE_COUNT) of Particle;
	
	PARTICLE_FIRE_DELAY : constant Time_Span := Seconds(1);
	type GameContext is tagged record
		enemies : EnemiesArray;

		particles : ParticleArray;
		lastParticleSpawn : Time;

		player : Entity.Player;
		score : Natural := 0;
	end record;
	type GameAccess is access GameContext;

	procedure Initialize(Self: in out GameContext);
	procedure UpdateEnemies(Self : in out GameAccess);
	procedure UpdateParticles(Self : in out GameAccess);
	procedure DrawFrame(Self : in out GameContext);
	function GameEnded(Self : in out GameContext) return Boolean;
	procedure HandleCollision(Self : in out GameContext;
				  A : in out Particle;
				  B : in Enemy);
	procedure CollisionCallback(Self : in out GameContext;
				    A : in out Entity.Entity'Class;
				    B : in out Entity.Entity'Class);

	-- Those are the three possible moves of the game
	-- They might be plugged with whatever user input desired
	procedure FireParticle(Self : in out GameContext);
	procedure PlayerMoveLeft(Self : in out GameContext);
	procedure PlayerMoveRight(Self : in out GameContext);

private

	procedure InitializeEnemies(Self : in out GameContext);
	procedure InitializePlayer(Self: in out GameContext);
	procedure InitializeParticles(Self: in out GameContext);
end Game;

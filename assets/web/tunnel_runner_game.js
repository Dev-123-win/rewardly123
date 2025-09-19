// Three.js global variables
let scene, camera, renderer;
let player;
let mixer; // For animation mixing
let animations = {}; // Store loaded animations
let clock = new THREE.Clock();

// Game state variables
let gameStarted = false;
let gameOver = false;
let score = 0;
let coinsCollected = 0;
let bestDistance = 0; // Loaded from Flutter
let playerSpeed = 0.15; // Initial player speed
let laneWidth = 1.5; // Width of each lane
let currentLane = 0; // -1 for left, 0 for center, 1 for right
let playerHeight = 0.5; // Approximate player height for collision
let playerRadius = 0.2; // Approximate player radius for collision
let obstacles = [];
let collectibles = [];
let tunnelSegments = [];
let segmentLength = 10; // Length of each tunnel segment
let segmentCount = 10; // Number of segments to keep in view
let lastSegmentZ = 0;

// Constants for game difficulty
const OBSTACLE_DENSITY = 0.3; // Probability of an obstacle in a segment
const COIN_DENSITY = 0.5; // Probability of coins in a segment
const OBSTACLE_TYPES = ['wall', 'gap', 'block']; // Example obstacle types
const COIN_VALUE = 10;

// HTML elements
const hudDistance = document.getElementById('distance-display');
const hudCoins = document.getElementById('coins-display');
const gameOverOverlay = document.getElementById('game-over-overlay');
const finalDistanceDisplay = document.getElementById('final-distance');
const finalCoinsDisplay = document.getElementById('final-coins');
const bestDistanceDisplay = document.getElementById('best-distance');
const reviveButton = document.getElementById('revive-button');
const restartButton = document.getElementById('restart-button');

// Initialize Three.js scene
function init() {
    // Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x1a1a1a); // Dark background

    // Camera
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    camera.position.set(0, 2, 5); // Position camera behind player
    camera.lookAt(0, playerHeight, 0);

    // Renderer
    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    // Lighting
    const ambientLight = new THREE.AmbientLight(0x404040);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(0, 10, 5);
    scene.add(directionalLight);

    // Load player models
    loadPlayerModels();

    // Event Listeners
    window.addEventListener('resize', onWindowResize, false);
    window.addEventListener('keydown', onKeyDown, false); // For desktop testing
    document.addEventListener('touchstart', onTouchStart, false);
    document.addEventListener('touchmove', onTouchMove, false);
    document.addEventListener('touchend', onTouchEnd, false);

    // UI button listeners
    reviveButton.addEventListener('click', requestReviveAd);
    restartButton.addEventListener('click', restartGame);

    // Start game loop
    animate();
}

// Handle window resize
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

// Load GLTF player models and animations
function loadPlayerModels() {
    const gltfLoader = new THREE.GLTFLoader();

    const modelsToLoad = [
        { name: 'player_run', path: 'assets/models/player_run.glb' },
        { name: 'player_jump', path: 'assets/models/player_jump.glb' },
        { name: 'player_slide', path: 'assets/models/player_slide.glb' },
        { name: 'player_fall', path: 'assets/models/player_fall.glb' },
    ];

    let loadedCount = 0;
    modelsToLoad.forEach(modelInfo => {
        gltfLoader.load(modelInfo.path, (gltf) => {
            const object = gltf.scene;
            object.scale.set(0.01, 0.01, 0.01); // Adjust scale as needed
            object.position.set(0, 0, 0); // Initial position
            object.traverse(child => {
                if (child.isMesh) {
                    child.castShadow = true;
                    child.receiveShadow = true;
                }
            });

            if (modelInfo.name === 'player_run') {
                player = object;
                scene.add(player);
                mixer = new THREE.AnimationMixer(player);
                // Play run animation initially
                const runClip = gltf.animations[0]; // Assuming first animation is run
                animations['run'] = mixer.clipAction(runClip);
                animations['run'].play();
            }

            // Store animations from all models
            gltf.animations.forEach(clip => {
                animations[modelInfo.name.replace('player_', '')] = mixer.clipAction(clip);
            });

            loadedCount++;
            if (loadedCount === modelsToLoad.length) {
                console.log('All player models loaded.');
                // Once models are loaded, generate initial tunnel
                generateInitialTunnel();
                gameStarted = true;
                sendGameStartedToFlutter();
            }
        }, undefined, (error) => {
            console.error('Error loading GLTF model:', modelInfo.path, error);
        });
    });
}

// Generate a single tunnel segment
function createTunnelSegment(zOffset) {
    const segment = new THREE.Group();
    const geometry = new THREE.PlaneGeometry(laneWidth * 3, segmentLength);
    const material = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.DoubleSide });
    const floor = new THREE.Mesh(geometry, material);
    floor.rotation.x = -Math.PI / 2;
    floor.position.z = zOffset;
    segment.add(floor);

    // Add walls
    const wallMaterial = new THREE.MeshBasicMaterial({ color: 0x555555, side: THREE.DoubleSide });
    const wallGeometry = new THREE.PlaneGeometry(segmentLength, 3); // Height 3
    const leftWall = new THREE.Mesh(wallGeometry, wallMaterial);
    leftWall.rotation.y = Math.PI / 2;
    leftWall.position.set(-laneWidth * 1.5, 1.5, zOffset); // Half height
    segment.add(leftWall);

    const rightWall = new THREE.Mesh(wallGeometry, wallMaterial);
    rightWall.rotation.y = -Math.PI / 2;
    rightWall.position.set(laneWidth * 1.5, 1.5, zOffset);
    segment.add(rightWall);

    // Add obstacles and collectibles randomly
    if (Math.random() < OBSTACLE_DENSITY) {
        const obstacle = createObstacle(zOffset);
        segment.add(obstacle);
        obstacles.push(obstacle);
    }
    if (Math.random() < COIN_DENSITY) {
        const coin = createCoin(zOffset);
        segment.add(coin);
        collectibles.push(coin);
    }

    return segment;
}

// Create a random obstacle
function createObstacle(zOffset) {
    const obstacleType = OBSTACLE_TYPES[Math.floor(Math.random() * OBSTACLE_TYPES.length)];
    const obstacleLane = Math.floor(Math.random() * 3) - 1; // -1, 0, 1
    let obstacle;

    if (obstacleType === 'wall') {
        const geometry = new THREE.BoxGeometry(laneWidth, 1, 0.2);
        const material = new THREE.MeshBasicMaterial({ color: 0xff0000 });
        obstacle = new THREE.Mesh(geometry, material);
        obstacle.position.set(obstacleLane * laneWidth, 0.5, zOffset);
    } else if (obstacleType === 'gap') {
        // A gap means no obstacle in this lane, but obstacles in others
        // For simplicity, we'll just create a block in a different lane
        const geometry = new THREE.BoxGeometry(laneWidth, 1, 0.2);
        const material = new THREE.MeshBasicMaterial({ color: 0xff0000 });
        obstacle = new THREE.Mesh(geometry, material);
        const otherLane = obstacleLane === 0 ? 1 : 0; // Place in a different lane
        obstacle.position.set(otherLane * laneWidth, 0.5, zOffset);
    } else if (obstacleType === 'block') {
        const geometry = new THREE.BoxGeometry(laneWidth, 0.5, 0.2);
        const material = new THREE.MeshBasicMaterial({ color: 0xff0000 });
        obstacle = new THREE.Mesh(geometry, material);
        obstacle.position.set(obstacleLane * laneWidth, 0.25, zOffset);
    }
    obstacle.userData.isObstacle = true;
    return obstacle;
}

// Create a coin collectible
function createCoin(zOffset) {
    const coinLane = Math.floor(Math.random() * 3) - 1; // -1, 0, 1
    const geometry = new THREE.CylinderGeometry(0.2, 0.2, 0.05, 16);
    const material = new THREE.MeshBasicMaterial({ color: 0xffd700 }); // Gold color
    const coin = new THREE.Mesh(geometry, material);
    coin.position.set(coinLane * laneWidth, 0.5, zOffset);
    coin.rotation.x = Math.PI / 2; // Make it stand upright
    coin.userData.isCoin = true;
    return coin;
}

// Generate initial tunnel segments
function generateInitialTunnel() {
    for (let i = 0; i < segmentCount; i++) {
        const zOffset = -i * segmentLength;
        const segment = createTunnelSegment(zOffset);
        scene.add(segment);
        tunnelSegments.push(segment);
        lastSegmentZ = zOffset;
    }
}

// Update game logic
function update(delta) {
    if (!gameStarted || gameOver) return;

    // Move player forward
    player.position.z -= playerSpeed * delta * 60; // Adjust speed based on delta

    // Move camera with player
    camera.position.z = player.position.z + 5;
    camera.lookAt(player.position.x, playerHeight, player.position.z);

    // Update score
    score += playerSpeed * delta;
    hudDistance.textContent = Math.floor(score).toString();

    // Update animations
    if (mixer) {
        mixer.update(delta);
    }

    // Regenerate tunnel segments
    if (player.position.z < tunnelSegments[0].position.z + segmentLength / 2) {
        const oldSegment = tunnelSegments.shift();
        scene.remove(oldSegment);
        // Remove obstacles and collectibles from the removed segment
        obstacles = obstacles.filter(obj => obj.parent !== oldSegment);
        collectibles = collectibles.filter(obj => obj.parent !== oldSegment);

        lastSegmentZ -= segmentLength;
        const newSegment = createTunnelSegment(lastSegmentZ);
        scene.add(newSegment);
        tunnelSegments.push(newSegment);
    }

    // Collision detection
    checkCollisions();

    // Send HUD update to Flutter
    sendHudUpdateToFlutter();
}

// Check for collisions with obstacles and collectibles
function checkCollisions() {
    const playerBox = new THREE.Box3().setFromObject(player);

    // Obstacle collision
    obstacles.forEach(obstacle => {
        if (obstacle.userData.isObstacle && playerBox.intersectsBox(new THREE.Box3().setFromObject(obstacle))) {
            console.log('Collision with obstacle!');
            endGame();
        }
    });

    // Collectible collision
    collectibles.forEach((coin, index) => {
        if (coin.userData.isCoin && playerBox.intersectsBox(new THREE.Box3().setFromObject(coin))) {
            console.log('Collected coin!');
            coinsCollected += COIN_VALUE;
            hudCoins.textContent = coinsCollected.toString();
            scene.remove(coin);
            collectibles.splice(index, 1); // Remove collected coin
            sendCollectCoinToFlutter(COIN_VALUE);
        }
    });
}

// Game over logic
function endGame() {
    gameOver = true;
    console.log('Game Over!');
    // Show game over overlay
    finalDistanceDisplay.textContent = Math.floor(score).toString();
    finalCoinsDisplay.textContent = coinsCollected.toString();
    bestDistanceDisplay.textContent = bestDistance.toString(); // Display best distance
    gameOverOverlay.style.display = 'flex';
    sendGameOverToFlutter(Math.floor(score), coinsCollected);
}

// Restart game logic
function restartGame() {
    gameOver = false;
    score = 0;
    coinsCollected = 0;
    playerSpeed = 0.15;
    currentLane = 0;
    player.position.set(0, 0, 0); // Reset player position
    gameOverOverlay.style.display = 'none';

    // Clear existing tunnel and regenerate
    tunnelSegments.forEach(segment => scene.remove(segment));
    tunnelSegments = [];
    obstacles = [];
    collectibles = [];
    lastSegmentZ = 0;
    generateInitialTunnel();

    // Reset HUD
    hudDistance.textContent = '0';
    hudCoins.textContent = '0';

    // Play run animation
    playAnimation('run');

    gameStarted = true;
    sendGameStartedToFlutter();
}

// Animation loop
function animate() {
    requestAnimationFrame(animate);
    const delta = clock.getDelta();
    update(delta);
    renderer.render(scene, camera);
}

// Player input handling (for desktop testing)
function onKeyDown(event) {
    if (gameOver) return;

    if (event.key === 'ArrowLeft' && currentLane > -1) {
        currentLane--;
        player.position.x = currentLane * laneWidth;
    } else if (event.key === 'ArrowRight' && currentLane < 1) {
        currentLane++;
        player.position.x = currentLane * laneWidth;
    } else if (event.key === 'ArrowUp') {
        // Jump animation
        playAnimation('jump');
    } else if (event.key === 'ArrowDown') {
        // Slide animation
        playAnimation('slide');
    }
}

// Touch input handling
let touchStartX = 0;
let touchStartY = 0;
let touchEndX = 0;
let touchEndY = 0;

function onTouchStart(event) {
    if (gameOver) return;
    touchStartX = event.touches[0].clientX;
    touchStartY = event.touches[0].clientY;
}

function onTouchMove(event) {
    if (gameOver) return;
    touchEndX = event.touches[0].clientX;
    touchEndY = event.touches[0].clientY;
}

function onTouchEnd(event) {
    if (gameOver) return;
    const dx = touchEndX - touchStartX;
    const dy = touchEndY - touchStartY;

    if (Math.abs(dx) > Math.abs(dy)) {
        // Horizontal swipe
        if (dx > 0 && currentLane < 1) {
            currentLane++;
            player.position.x = currentLane * laneWidth;
        } else if (dx < 0 && currentLane > -1) {
            currentLane--;
            player.position.x = currentLane * laneWidth;
        }
    } else {
        // Vertical swipe
        if (dy < 0) {
            // Swipe up (jump)
            playAnimation('jump');
        } else if (dy > 0) {
            // Swipe down (slide)
            playAnimation('slide');
        }
    }
    // Reset touch coordinates
    touchStartX = 0;
    touchStartY = 0;
    touchEndX = 0;
    touchEndY = 0;
}

// Play a specific animation
function playAnimation(name) {
    if (animations[name]) {
        mixer.stopAllAction();
        animations[name].play();
        // After a short delay, transition back to run animation
        setTimeout(() => {
            if (!gameOver) {
                mixer.stopAllAction();
                animations['run'].play();
            }
        }, animations[name].getClip().duration * 1000); // Duration of the animation clip
    }
}

// Flutter communication functions
function sendGameStartedToFlutter() {
    if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify({ type: 'gameStarted' }));
    }
}

function sendHudUpdateToFlutter() {
    if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify({
            type: 'updateHud',
            distance: Math.floor(score),
            coins: coinsCollected
        }));
    }
}

function sendCollectCoinToFlutter(amount) {
    if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify({ type: 'collectCoin', amount: amount }));
    }
}

function sendGameOverToFlutter(distance, coins) {
    if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify({ type: 'gameOver', distance: distance, coins: coins }));
    }
}

function requestReviveAd() {
    if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify({ type: 'requestAd', adType: 'revive' }));
    }
}

function requestBonusAd() {
    if (window.FlutterChannel) {
        window.FlutterChannel.postMessage(JSON.stringify({ type: 'requestAd', adType: 'bonus' }));
    }
}

// Function called by Flutter to set initial game state (e.g., best distance)
window.setInitialGameState = function(initialBestDistance) {
    bestDistance = initialBestDistance;
    bestDistanceDisplay.textContent = bestDistance.toString();
    console.log('Initial best distance set:', bestDistance);
};

// Function called by Flutter to handle ad results
window.handleAdResult = function(success, adType, rewardAmount) {
    if (success) {
        if (adType === 'revive') {
            console.log('Revive successful!');
            gameOver = false; // Allow game to continue
            gameOverOverlay.style.display = 'none';
            player.position.z -= 5; // Move player back slightly to avoid immediate collision
            playAnimation('run');
            // Optionally give some invincibility frames
        } else if (adType === 'bonus') {
            console.log('Bonus ad successful! Awarded:', rewardAmount);
            coinsCollected += rewardAmount;
            hudCoins.textContent = coinsCollected.toString();
        }
    } else {
        console.log('Ad failed or not available for type:', adType);
        if (adType === 'revive') {
            // If revive ad failed, keep game over state
            gameOverOverlay.style.display = 'flex';
        }
    }
};

// Initialize the game
init();

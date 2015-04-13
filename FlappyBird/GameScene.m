//
//  GameScene.m
//  FlappyBird
//
//  Created by Nguyen Van Phi on 4/13/15.
//  Copyright (c) 2015 Nguyen Van Phi. All rights reserved.
//

#import "GameScene.h"

@interface GameScene(){
    SKSpriteNode *birdSprite;
    SKColor *skyColor;
    SKTexture *pipe1Texture;
    SKTexture *pipe2Texture;
    SKAction *moveandremovePipes;
}
@end
@implementation GameScene

static NSInteger const KVerticalPipeGap = 100;

-(id) initWithSize:(CGSize)size{
    if (self == [super initWithSize:size]) {
        SKTexture *bird1Texture = [SKTexture textureWithImageNamed:@"Bird1"];
        bird1Texture.filteringMode = SKTextureFilteringNearest;
        
        SKTexture *bird2Texture = [SKTexture textureWithImageNamed:@"Bird2"];
        bird2Texture.filteringMode = SKTextureFilteringNearest;
        
        SKAction *flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[bird1Texture,bird2Texture] timePerFrame:0.2]];
        birdSprite = [SKSpriteNode spriteNodeWithTexture:bird1Texture];
        [birdSprite setScale:2.0];
        birdSprite.position = CGPointMake(self.frame.size.width/4, CGRectGetMidY(self.frame));
        [birdSprite runAction:flap];
        
        birdSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:birdSprite.size.height/2];
        birdSprite.physicsBody.dynamic = YES;
        birdSprite.physicsBody.allowsRotation = NO;
        [self addChild:birdSprite];
        
        skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
        [self setBackgroundColor: skyColor];
        
        SKTexture *groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
        groundTexture.filteringMode = SKTextureFilteringNearest;
        
        SKAction *moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02*groundTexture.size.width*2];
        SKAction *resetGroundSpite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
        SKAction *moveGroundSpriteForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite,resetGroundSpite]]];
        
        for (int i = 0; i < 2 + self.frame.size.width/(groundTexture.size.width*2); i++) {
            SKSpriteNode *groundSprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
            [groundSprite setScale:2.0];
            groundSprite.position = CGPointMake(i*groundSprite.size.width, groundSprite.size.height/2);
            [groundSprite runAction:moveGroundSpriteForever];
            [self addChild:groundSprite];
        }
        
        SKTexture *skyLineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
        skyLineTexture.filteringMode = SKTextureFilteringNearest;
        
        SKAction *moveSkyLineSprite = [SKAction moveByX:-skyLineTexture.size.width*2 y:0 duration:0.1*skyLineTexture.size.width*2];
        SKAction *resetSkyLineSpite = [SKAction moveByX:skyLineTexture.size.width*2 y:0 duration:0];
        SKAction *moveSkyLineSpriteForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkyLineSprite,resetSkyLineSpite]]];
        
        for (int i = 0 ; i < 2 + self.frame.size.width/(skyLineTexture.size.width*2); i++) {
            SKSpriteNode *skyLineSpite = [SKSpriteNode spriteNodeWithTexture:skyLineTexture];
            [skyLineSpite setScale:2.0];
            skyLineSpite.zPosition = -20;
            skyLineSpite.position = CGPointMake(i * skyLineSpite.size.width, skyLineSpite.size.height + groundTexture.size.height);
            [skyLineSpite runAction:moveSkyLineSpriteForever];
            [self addChild:skyLineSpite];
        }
        
        SKNode *dummy = [SKNode node];
        dummy.position = CGPointMake(0, groundTexture.size.height);
        dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundTexture.size.height *2)];
        dummy.physicsBody.dynamic = NO;
        [self addChild:dummy];
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0);
        
        // create pipes;
        pipe1Texture = [SKTexture textureWithImageNamed:@"Pipe1"];
        pipe1Texture.filteringMode = SKTextureFilteringNearest;
        pipe2Texture = [SKTexture textureWithImageNamed:@"Pipe2"];
        pipe2Texture.filteringMode = SKTextureFilteringNearest;
        
        CGFloat distanceToMove = self.frame.size.width + pipe1Texture.size.width*2;
        SKAction *movePipes = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
        SKAction *removePipes = [SKAction removeFromParent];
        moveandremovePipes = [SKAction sequence:@[movePipes,removePipes]];
        
        SKAction *spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
        SKAction *delay = [SKAction waitForDuration:2.0];
        SKAction *spawnThenDelay = [SKAction sequence:@[spawn,delay]];
        SKAction *spawnThenDelayForever = [SKAction  repeatActionForever:spawnThenDelay];
        [self runAction:spawnThenDelayForever];
        
    }
    return self;
}

-(void) spawnPipes{
    SKNode *pipePair = [SKNode node];
    pipePair.position = CGPointMake(self.frame.size.width + pipe1Texture.size.width, 0);
    pipePair.zPosition = -10;
    
    CGFloat y = arc4random() % (NSInteger)(self.frame.size.height/3);
    
    SKSpriteNode *pipe1Sprite = [SKSpriteNode spriteNodeWithTexture:pipe1Texture];
    [pipe1Sprite setScale: 2.0];
    pipe1Sprite.position = CGPointMake(0, y);
    pipe1Sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1Sprite.size];
    pipe1Sprite.physicsBody.dynamic = NO;
    [pipePair addChild:pipe1Sprite];
    
    SKSpriteNode *pipe2Sprite = [SKSpriteNode spriteNodeWithTexture:pipe2Texture];
    [pipe2Sprite setScale: 2.0];
    pipe2Sprite.position = CGPointMake(0, y + pipe1Sprite.size.height + KVerticalPipeGap);
    pipe2Sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2Sprite.size];
    pipe2Sprite.physicsBody.dynamic = NO;
    [pipePair addChild:pipe2Sprite];
    
//    SKAction *movePipes = [SKAction repeatActionForever:[SKAction moveByX:-1 y:0 duration:0.02]];
    [pipePair runAction:moveandremovePipes];
    
    [self addChild:pipePair];
}
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    birdSprite.physicsBody.velocity = CGVectorMake(0, 0);
    [birdSprite.physicsBody applyImpulse:CGVectorMake(0, 4)];
}

CGFloat clamp(CGFloat min, CGFloat max, CGFloat value){
    if(value > max){
        return max;
    }
    if (value < min) {
        return min;
    }
    return value;
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    birdSprite.zPosition = clamp(-1, 0.5, birdSprite.physicsBody.velocity.dy*(birdSprite.physicsBody.velocity.dy < 0 ? 0.03 : 0.01));
}

@end

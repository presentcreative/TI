// Copyright (c) 2011 Space Dog Books, Inc. All Rights Reserved.
// $Id$

#import <Foundation/Foundation.h>


@interface NSDictionary (ElementAndPropertyValues)

// General properties
@property (readonly) NSArray* elements;

@property (readonly) BOOL isOnLayer;

@property (readonly) BOOL isOnView;

@property (readonly) BOOL isPDFBased;

@property (readonly) NSArray* pages;

@property (readonly) NSUInteger numPages;

@property (readonly) BOOL big;

@property (readonly) NSString* type;

@property (readonly) NSArray* types;

@property (readonly) NSString* assetType;

@property (readonly) NSArray* propertyList;

@property (readonly) BOOL hasTrigger;

@property (readonly) NSDictionary* trigger;

@property (readonly) BOOL hasTriggers;

@property (readonly) NSArray* triggers;

@property (readonly) BOOL hasTriggerMethod;

@property (readonly) NSString* triggerMethod;

@property (readonly) BOOL allowsConcurrentTrigger;

@property (readonly) NSInteger dataValue;

@property (readonly) BOOL hasShakeTrigger;

@property (readonly) CGFloat shakeThreshold;

@property (readonly) BOOL hasTiltTrigger;

@property (readonly) CGFloat triggerAngle;

@property (readonly) NSUInteger numberOfTouchesRequired;

@property (readonly) NSString* swipeDirection;

@property (readonly) NSString* tiltNotificationEvent;

@property (readonly) BOOL hasAnimations;

@property (readonly) NSArray* animations;

@property (readonly) NSString* animationType;

@property (readonly) BOOL isCustomAnimation;

@property (readonly) NSString* animationClass;

@property (readonly) BOOL isClassBased;

@property (readonly) NSString* customClass;

@property (readonly) BOOL hasAnimationGroup;

@property (readonly) NSString* animationGroup;

@property (readonly) NSArray* shakeTriggeredAnimations;

@property (readonly) BOOL hasSequences;

@property (readonly) NSArray* sequences;

@property (readonly) int numFrames;

@property (readonly) BOOL hasNumRepeats;

@property (readonly) NSUInteger numRepeats;

@property (readonly) NSUInteger numImages;

@property (readonly) BOOL hasSegments;

@property (readonly) NSArray* segments;

@property (readonly) int numSegments;

@property (readonly) NSInteger pageNumber;

@property (readonly) NSArray* regions;

@property (readonly) BOOL hasRepeatType;

@property (readonly) NSString* repeatType;

@property (readonly) BOOL isSequenced;

@property (readonly) NSString* propertyId;

@property (readonly) BOOL hasAutoReverse;

@property (readonly) BOOL autoReverse;

@property (readonly) BOOL hasTimingFunctionName;

@property (readonly) NSString* timingFunctionName;

@property (readonly) BOOL hasAnchorPoint;

@property (readonly) CGPoint anchorPoint;

@property (readonly) BOOL isResourceBased;

@property (readonly) NSString* resource;

@property (readonly) BOOL isResourceBaseBased;

@property (readonly) NSString* resourceBase;

@property (readonly) NSArray* resources;

@property (readonly) BOOL hasFrame;

@property (readonly) CGRect frame;

@property (readonly) BOOL hasBounds;

@property (readonly) CGRect bounds;

@property (readonly) NSString* scrollMode;

@property (readonly) CGFloat scrollIncrement;

@property (readonly) CGFloat updatePeriod;

@property (readonly) BOOL hasMinX;

@property (readonly) CGFloat minX;

@property (readonly) BOOL hasMaxX;

@property (readonly) CGFloat maxX;

@property (readonly) BOOL hasMinY;

@property (readonly) CGFloat minY;

@property (readonly) BOOL hasMaxY;

@property (readonly) CGFloat maxY;

@property (readonly) BOOL hasViewFrame;

@property (readonly) CGRect viewFrame;

@property (readonly) BOOL hasInitialAlpha;

@property (readonly) CGFloat initialAlpha;

@property (readonly) CGFloat startAlpha;

@property (readonly) CGFloat endAlpha;

@property (readonly) BOOL hasDuration;

@property (readonly) CGFloat duration;

@property (readonly) CGFloat repeatDelay;

@property (readonly) CGFloat repeatDelayMin;

@property (readonly) CGFloat repeatDelayMax;

@property (readonly) CGFloat reverseDelay;

@property (readonly) BOOL hasContentsGravity;

@property (readonly) NSString* contentsGravity;

@property (readonly) BOOL hasTransitions;

@property (readonly) NSArray* transitions;

@property (readonly) NSDictionary* creationSpec;

@property (readonly) NSString* createdBy;

@property (readonly) BOOL hasSoundEffect;

@property (readonly) NSDictionary* soundEffect;

@property (readonly) NSUInteger minTouches;

@property (readonly) NSUInteger maxTouches;

@property (readonly) BOOL hasPostAnimationNotification;

@property (readonly) NSArray* notifications;

@property (readonly) NSString* postAnimationNotification;

@property (readonly) NSString* state;

@property (readonly) NSArray* subAnimations;

@property (readonly) CGFloat startAngle;

@property (readonly) CGFloat endAngle;

@property (readonly) BOOL hasDelay;

@property (readonly) CGFloat delay;

@property (readonly) BOOL hasViewBasedAssets;

@property (readonly) BOOL hasName;

@property (readonly) NSString* name;

@property (readonly) BOOL hasToggleProperty;

@property (readonly) BOOL toggle;

@property (readonly) NSArray* resourceNames;

@property (readonly) NSNumber* fromValue;

@property (readonly) NSString* fromValueString;

@property (readonly) NSNumber* toValue;

@property (readonly) NSString* toValueString;

@property (readonly) BOOL oneShot;

@property (readonly) BOOL hasPostExecutionNotification;

@property (readonly) NSString* postExecutionNotification;

@property (readonly) NSString* completionNotification;

@property (readonly) NSString* inPlayNotification;

@property (readonly) NSUInteger inPlayNotificationIndex;

@property (readonly) CGFloat accelerometerSampleRate;

@property (readonly) BOOL unpatterned;

@property (readonly) NSUInteger initialFrame;

// Animation-specific properties
@property (readonly) NSDictionary* animationProperties;

@property (readonly) NSString* keyPath;

@property (readonly) CGFloat xDelta;

@property (readonly) CGFloat yDelta;

@property (readonly) BOOL updateToFinalPosition;

@property (readonly) BOOL updateToFinalValue;

@property (readonly) CGFloat maximumExtension;

@property (readonly) CGFloat springTension;

// DecayingZRotation-specific properties
@property (readonly) double omega;

@property (readonly) double zeta;

@property (readonly) double startValueDouble;

@property (readonly) double endValueDouble;

@property (readonly) NSUInteger steps;

// SegmentedImage-specific properties
@property (readonly) BOOL hasCollapseStartX;
@property (readonly) CGFloat collapseStartX;
@property (readonly) BOOL hasExtensionStartX;
@property (readonly) CGFloat extensionStartX;
@property (readonly) NSString* closeSound;
@property (readonly) NSString* openSound;
@property (readonly) CGFloat closeTriggerX;
@property (readonly) CGFloat openTriggerX;

// ChapterMenu-specific properties
@property (readonly) NSString* scrollTopResource;
@property (readonly) CGRect scrollTopFrame;

@property (readonly) NSString* scrollBottomResource;
@property (readonly) CGRect scrollBottomFrame;

@property (readonly) NSString* scrollBackResource;
@property (readonly) CGRect scrollBackFrame;
@property (readonly) CGFloat scrollBackInitialHeight;

@property (readonly) CGRect scrollToggleHotspot;
@property (readonly) CGFloat scrollTopMinY;
@property (readonly) CGFloat scrollTopMaxY;

@property (readonly) CGRect scrollerFrame;

@property (readonly) CGFloat dragMinX;
@property (readonly) CGFloat dragMaxX;
@property (readonly) CGRect hotspot;

@property (readonly) NSArray* helpDescriptors;
@property (readonly) BOOL autoStart;
@property (readonly) NSString* arrowDirection;

@property (readonly) BOOL respectSequenceInProgress;

@property (readonly) BOOL stepTriggerRequired;
@property (readonly) BOOL autoResetToBase;


// TopCloud-specific properties
@property (readonly) CGFloat stepMin;
@property (readonly) CGFloat stepMax;

// MultipleImageSequence-specific properties
@property (readonly) BOOL hasPropertyEffects;
@property (readonly) NSArray* propertyEffects;
@property (readonly) NSArray* effects;

@property (readonly) NSString* offset;
@property (readonly) NSNumber* index;
@property (readonly) NSString* property;
@property (readonly) NSString* imageIndices;


// AmbientSound-specific properties
@property (readonly) NSInteger numLoops;
@property (readonly) CGFloat fadeInDuration;
@property (readonly) CGFloat fadeInGain;
@property (readonly) CGFloat fadeOutDuration;
@property (readonly) CGFloat fadeOutGain;
@property (readonly) CGFloat maxDuration;
@property (readonly) BOOL preload;
@property (readonly) BOOL preloadAsync;
@property (readonly) BOOL playAsync;


// TorchAndEyes-specific properties
@property (readonly) NSDictionary* torchLayer;
@property (readonly) NSDictionary* darknessLayer;
@property (readonly) NSString* backgroundImage;
@property (readonly) NSUInteger eyePairs;
@property (readonly) NSDictionary* torchSoundEffect;

-(NSDictionary*)eyePairSpecForIndex:(NSUInteger)index;

@property (readonly) NSDictionary* torchSpec;

// LockAndKey-specific properties
@property (readonly) NSDictionary* leftLockLayer;
@property (readonly) NSDictionary* innerLockLayer;
@property (readonly) NSDictionary* rightLockLayer;
@property (readonly) NSDictionary* keyLayer;
@property (readonly) NSDictionary* barLayer;
@property (readonly) CGFloat lockThreshold;
@property (readonly) CGFloat unlockThreshold;
@property (readonly) NSString* unlockSoundEffect;
@property (readonly) NSString* lockSoundEffect;

// ShipSailsAndPully-specific properties
@property (readonly) NSDictionary* bottomFrontSail;
@property (readonly) NSDictionary* bottomMiddleSail;
@property (readonly) NSDictionary* bottomRearSail;
@property (readonly) NSDictionary* hookLayer;
@property (readonly) NSDictionary* centerFrontLayer;
@property (readonly) NSDictionary* centerMiddleLayer;
@property (readonly) NSDictionary* centerRearLayer;
@property (readonly) NSDictionary* topFrontLayer;
@property (readonly) NSDictionary* topMiddleLayer;
@property (readonly) NSDictionary* topRearLayer;
@property (readonly) CGFloat furlThreshold;
@property (readonly) CGFloat unfurlThreshold;
@property (readonly) NSDictionary* unfurlSoundEffect;
@property (readonly) NSDictionary* furlSoundEffect;

// ToyBoat-specific properties
@property (readonly) NSDictionary* islandLayer;
@property (readonly) NSDictionary* boatLayer;
@property (readonly) NSDictionary* waterLayer;
@property (readonly) NSDictionary* springAnimation;
@property (readonly) NSString* shipPlunkSoundEffect;

// RandomNotificationGenerator properties
@property (readonly) NSString* notificationNameBase;
@property (readonly) NSArray* suffixes;
@property (readonly) CGFloat minDelay;
@property (readonly) CGFloat maxDelay;

// Sunset-specific properties
@property (readonly) NSDictionary* skyLayer;
@property (readonly) NSDictionary* sunLayer;
@property (readonly) NSDictionary* foregroundLayer;
@property (readonly) NSDictionary* blackLayer;
@property (readonly) NSDictionary* theEndLayer;
@property (readonly) NSArray* pirates;

// Ben Gunn Eyes-spot properties
@property (readonly) NSDictionary* socketLayer;
@property (readonly) NSDictionary* eyesLayer;

// Compass-spot properties
@property (readonly) NSDictionary* compassLayer;
@property (readonly) NSDictionary* needleLayer;

// Pipe-spot properties
@property (readonly) NSDictionary* pipeLayer;
@property (readonly) NSDictionary* tobaccoLayer;
@property (readonly) NSDictionary* flameLayer;
@property (readonly) NSDictionary* smokeLayer;
@property (readonly) CGRect dropZone;

// JimAtTheHelm properties
@property (readonly) NSDictionary* wheelLayer;
@property (readonly) NSDictionary* helmLayer;
@property (readonly) NSDictionary* sailPortLayer;
@property (readonly) NSDictionary* sailStarbordLayer;
@property (readonly) NSDictionary* ropeStaticLayer;
@property (readonly) NSDictionary* ropeCWLayer;
@property (readonly) NSDictionary* ropeCCWLayer;
@property (readonly) CGFloat yMovementThreshold;
@property (readonly) NSString* wheelSoundEffect;

// RumBottle properties
@property (readonly) NSDictionary* sloshingSequence1;
@property (readonly) NSDictionary* sloshingSequence2;
@property (readonly) NSString* rumBottleSoundEffect;

// RollingBottle properties
@property (readonly) NSDictionary* rollingSequences;
@property (readonly) NSString* singleTurnSoundEffect;
@property (readonly) NSString* l2RSoundEffect;
@property (readonly) NSString* r2LSoundEffect;

// Cups properties
@property (readonly) NSDictionary* leftCupLayer;
@property (readonly) NSDictionary* rightCupLayer;
@property (readonly) NSString* cupSoundEffect;

// RoughSeas properties
@property (readonly) NSDictionary* borderLayer;
@property (readonly) NSDictionary* shipLayer;
@property (readonly) NSDictionary* seaLayer;
@property (readonly) NSDictionary* flickeringLightLayer;
@property (readonly) NSDictionary* choppyWave1Layer;
@property (readonly) NSDictionary* choppyWave2Layer;
@property (readonly) NSDictionary* rowBoatLayer;

// CreditsPage properties
@property (readonly) NSString* bottomImageResource;
@property (readonly) NSString* topImageResource;
@property (readonly) NSDictionary* chimneySmokeLayer;
@property (readonly) NSDictionary* creditsLayer;
@property (readonly) NSArray* creditSpecs;
@property (readonly) CGFloat timeOffset;
@property (readonly) CGFloat scrollDuration;
@property (readonly) CGFloat displayDuration;
@property (readonly) CGFloat animationDuration;
@property (readonly) NSDictionary* skipIntroButton;
@property (readonly) NSDictionary* beginBookButton;
@property (readonly) NSDictionary* blackDog1Layer;
@property (readonly) NSDictionary* porter1Layer;
@property (readonly) NSDictionary* blackDog2Layer;
@property (readonly) NSDictionary* porter2Layer;
@property (readonly) NSDictionary* blackDogAndPorter1Layer;
@property (readonly) NSDictionary* blackDogAndPorter2Layer;
@property (readonly) NSDictionary* tree1Layer;
@property (readonly) NSDictionary* trees2Layer;
@property (readonly) NSArray* pathPoints;
@property (readonly) CGPoint finalPosition;

// ASeagull properties
@property (readonly) NSDictionary* seagullLayer;
@property (readonly) CGFloat fadeThreshold;

// AGoldSwipe properties
@property (readonly) NSDictionary* swipe1Layer;
@property (readonly) NSDictionary* swipe2Layer;

// ALink properties
@property (readonly) NSString* address;

// Trigger properties
@property (readonly) CGFloat interval;
@property (readonly) BOOL repeats;
@property (readonly) BOOL hasGatedProperty;
@property (readonly) BOOL gated;
@property (readonly) NSString* enablingNotification;
@property (readonly) NSString* disablingNotification;
@property (readonly) BOOL autoBecomeAccelerometerDelegate;
@property (readonly) BOOL waitForTrigger;


// ACargoAndPully properties
@property (readonly) NSDictionary* cargoView;
@property (readonly) NSString* cargoDownSoundEffect;
@property (readonly) NSString* cargoUpSoundEffect;

// AVines properties
@property (readonly) NSDictionary* leftVine;
@property (readonly) NSDictionary* rightVine;

// ABoatAndStuff properties
@property (readonly) NSDictionary* stuffLayer;

// AWarAtSea properties
@property (readonly) NSDictionary* backgroundLayer;
@property (readonly) NSDictionary* wavesLayer;
@property (readonly) NSDictionary* smolletAnimation;
@property (readonly) NSDictionary* rifleHammerAnimation;
@property (readonly) NSDictionary* muzzleFlashAnimation;
@property (readonly) NSDictionary* muzzleSmokeAnimation;

// ACoins properties
@property (readonly) NSDictionary* coin1;
@property (readonly) NSDictionary* coin2;
@property (readonly) NSDictionary* coin3;
@property (readonly) NSDictionary* coin4;
@property (readonly) NSDictionary* coin5;

// ABobbingPainter properties
@property (readonly) NSDictionary* bobbingShipLayer;
@property (readonly) NSDictionary* painterAnimation;

// AWindows properties
@property (readonly) NSArray* windowSpecs;
@property (readonly) NSString* windowCoordinates;
@property (readonly) NSString* frameKeyTemplate;

// ASmollet properties
@property (readonly) NSDictionary* smolletLayer;
@property (readonly) NSDictionary* swordAnimation;
@property (readonly) NSDictionary* swordGleam;
@property (readonly) NSDictionary* hatLayer;

// TurnSpec properties
@property (readonly) NSArray* turnSpecs;
@property (readonly) CGFloat startTime;
@property (readonly) NSString* layerName;
@property (readonly) CGFloat rotation;

// Coconut properties
@property (readonly) NSDictionary* coconut1Layer;
@property (readonly) NSDictionary* coconut2Layer;
@property (readonly) NSDictionary* coconut3Layer;

// ABlownLeaves properties
@property (readonly) NSDictionary* leaf1Layer;
@property (readonly) NSDictionary* leaf2Layer;
@property (readonly) NSDictionary* leaf3Layer;

// ALightBeam properties
@property (readonly) NSDictionary* particleAnimation;
@property (readonly) NSDictionary* beamLayer;

// APoppingCork properties
@property (readonly) NSDictionary* bottleLayer;
@property (readonly) NSDictionary* corkAnimation;

// Physics Engine related properties
@property (readonly) NSString* objectObjectCollisionSoundEffect;
@property (readonly) NSString* objectWallCollisionSoundEffect;

// Lantern related properties
@property (readonly) NSString* lanternSoundEffect;

@end

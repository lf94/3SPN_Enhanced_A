class NecroEffectB extends xEmitter;

#exec TEXTURE IMPORT NAME=SmokeTex FILE=Textures\Smoke.tga GROUP=Textures MIPS=On ALPHA=1 DXT=5

defaultproperties
{
     mSpawningType=ST_Explode
     mRegenPause=True
     mRegenOnTime(0)=0.100000
     mRegenOnTime(1)=0.100000
     mRegenOffTime(0)=5.000000
     mRegenOffTime(1)=5.000000
     mLifeRange(0)=50.000000
     mLifeRange(1)=50.000000
     mRegenRange(0)=100.000000
     mRegenRange(1)=100.000000
     mPosDev=(X=12.000000,Y=12.000000,Z=12.000000)
     mSpeedRange(0)=1.000000
     mSpeedRange(1)=1.000000
     mPosRelative=True
     mAirResistance=-1.000000
     mSpinRange(0)=200.000000
     mSpinRange(1)=200.000000
     mSizeRange(0)=110.000000
     mSizeRange(1)=110.000000
     mColorRange(0)=(B=0,G=100,R=0)
     mAttenKa=0.000000
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=3.000000
     Skins(0)=Texture'3SPN_Enhanced_A.Textures.SmokeTex'
     Style=STY_Additive
}

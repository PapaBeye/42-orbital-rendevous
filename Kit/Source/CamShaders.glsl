/*    This file is distributed with 42,                               */
/*    the (mostly harmless) spacecraft dynamics simulation            */
/*    created by Eric Stoneking of NASA Goddard Space Flight Center   */

/*    Copyright 2010 United States Government                         */
/*    as represented by the Administrator                             */
/*    of the National Aeronautics and Space Administration.           */

/*    No copyright is claimed in the United States                    */
/*    under Title 17, U.S. Code.                                      */

/*    All Other Rights Reserved.                                      */


/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/*  World Vertex Shader                                               */

GLchar WorldVtxText[] = {"                                             \
                                                                       \
varying float RingTexCoord;                                            \
varying vec3 PosVec;                                                   \
varying vec3 LightVec;                                                 \
                                                                       \
void main(void)                                                        \
{                                                                      \
      float k;                                                         \
                                                                       \
      gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;          \
                                                                       \
      PosVec = normalize(gl_Normal);                                   \
      LightVec = normalize(vec3(                                       \
         gl_ModelViewMatrixInverse*gl_LightSource[0].position));       \
      k = step(0.0,-PosVec.z*LightVec.z)                               \
         *(-PosVec.z/LightVec.z);                                      \
      RingTexCoord =                                                   \
         clamp(length(vec2(PosVec+k*LightVec))-1.5,-0.5,10.0);         \
}                                                                      \
"};

/**********************************************************************/
/*  World Fragment Shader                                             */

GLchar WorldFragText[] = {"                                            \
                                                                       \
uniform samplerCube MapTexture;                                        \
uniform samplerCube BumpTexture;                                       \
uniform samplerCube CloudGlossTexture;                                 \
uniform sampler1D RingTexture;                                         \
uniform vec3 PovPosW;                                                  \
uniform bool HasAtmo;                                                  \
uniform vec3 AtmoColor;                                                \
uniform float MaxHt;                                                   \
                                                                       \
varying float RingTexCoord;                                            \
varying vec3 PosVec;                                                   \
varying vec3 LightVec;                                                 \
                                                                       \
void main(void)                                                        \
{                                                                      \
      vec4 Ring;                                                       \
      float RingCoord;                                                 \
      float DiffIllum;                                                 \
      float SpecIllum;                                                 \
      vec3 HalfVec;                                                    \
      float NoH;                                                       \
      float Gloss;                                                     \
      float AtmoFrac;                                                  \
      vec3 RelPos,DirVec;                                              \
      float Ra,Alt,NadirAng,HorNadirAng,fz,fg;                         \
                                                                       \
/* .. Illumination */                                                  \
      /* Normal Vector */                                              \
      vec3 Normal =                                                    \
         normalize(PosVec+vec3(textureCube(BumpTexture,PosVec))-0.5);  \
      vec2 CloudGloss = vec2(textureCube(CloudGlossTexture,PosVec));   \
      /* Check for Ring Shadow */                                      \
      RingCoord = RingTexCoord;                                        \
      Ring = texture1D(RingTexture,RingCoord);                         \
      /* Diffuse Illumination */                                       \
      if (HasAtmo) {                                                   \
         DiffIllum = smoothstep(0.0,1.0,                               \
            5.0*dot(Normal,LightVec)*(1.0-Ring.a));                    \
      }                                                                \
      else {                                                           \
         DiffIllum = smoothstep(0.0,1.0,                               \
            dot(Normal,LightVec)*(1.0-Ring.a));                        \
      }                                                                \
      /* Specular Illumination */                                      \
      HalfVec = normalize(LightVec+normalize(PovPosW));                \
      Gloss = DiffIllum*CloudGloss.g;                                  \
      NoH = clamp(dot(Normal,HalfVec),0.0,1.0);                        \
      SpecIllum = Gloss*pow(NoH,gl_FrontMaterial.shininess);           \
                                                                       \
/* .. Perturb Material if Desired */                                   \
      vec4 MapColor =                                                  \
         vec4(vec3(textureCube(MapTexture,PosVec)),1.0);               \
                                                                       \
/* .. Atmosphere */                                                    \
      if (HasAtmo) {                                                   \
         RelPos = PovPosW - PosVec;                                    \
         Ra = length(PovPosW);                                         \
         Alt = Ra - 1.0;                                               \
         DirVec = normalize(RelPos);                                   \
         NadirAng = 3.14159-acos(DirVec[2]);                           \
         HorNadirAng = asin(1.0/length(PovPosW));                      \
         fz = 1.2*sqrt(Alt/MaxHt);                                     \
         fg = 0.5*NadirAng/HorNadirAng;                                \
         AtmoFrac = clamp(fz*fg,0.0,0.5);                              \
         MapColor = AtmoFrac*vec4(AtmoColor,1.0) + (1.0-AtmoFrac)*MapColor;      \
      }                                                                \
                                                                       \
/* .. Compute Colors */                                                \
      /* Sum Ambient with Diffuse Term */                              \
      vec4 Diffuse = gl_FrontLightModelProduct.sceneColor;             \
      Diffuse.a = 1.0;                                                 \
      vec4 Spec = vec4(0.0,0.0,0.0,1.0);                               \
      /* Primary Color */                                              \
      Diffuse += DiffIllum*gl_LightSource[0].diffuse;                  \
      /* Secondary Color */                                            \
      Spec += SpecIllum*gl_LightSource[0].specular;                    \
      /* Ground Color */                                               \
      vec4 GndColor = Diffuse*MapColor+                                \
         Spec*gl_FrontMaterial.specular;                               \
                                                                       \
      /* Attenuate through Clouds */                                   \
      gl_FragColor = mix(GndColor,Diffuse,CloudGloss.r);               \
}                                                                      \
"};
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/*  Ring Vertex Shader                                                */

GLchar RingVtxText[] = {"                                              \
                                                                       \
varying vec3 PosVec;                                                   \
varying vec3 LightVec;                                                 \
                                                                       \
void main(void)                                                        \
{                                                                      \
      gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;          \
                                                                       \
      gl_TexCoord[0] = gl_TextureMatrix[0]*gl_MultiTexCoord0;          \
                                                                       \
      PosVec = vec3(gl_Vertex);                                        \
      LightVec = normalize(vec3(                                       \
         gl_ModelViewMatrixInverse*gl_LightSource[0].position));       \
}                                                                      \
"};

/**********************************************************************/
/*  Ring Fragment Shader                                              */

GLchar RingFragText[] = {"                                             \
                                                                       \
uniform sampler1D RingTexture;                                         \
varying vec3 PosVec;                                                   \
varying vec3 LightVec;                                                 \
                                                                       \
void main(void)                                                        \
{                                                                      \
      float AoL;                                                       \
      vec3 ProjVec;                                                    \
                                                                       \
      vec4 RingColor =                                                 \
         texture1D(RingTexture,gl_TexCoord[0].s);                      \
      vec4 DiffIllum = gl_FrontLightModelProduct.sceneColor;           \
      DiffIllum.a = 1.0;                                               \
      AoL = dot(PosVec,LightVec);                                      \
      ProjVec = PosVec-AoL*LightVec;                                   \
      DiffIllum += max(step(1.0,dot(ProjVec,ProjVec)),                 \
         step(0.0,AoL))*gl_LightSource[0].diffuse;                     \
      gl_FragColor = RingColor*clamp(DiffIllum,0.0,1.0);               \
}                                                                      \
"};
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/*  Atmo Vertex Shader                                                */

GLchar AtmoVtxText[] = {"                                              \
                                                                       \
varying vec3 PosVecL;                                                  \
varying vec3 SunVecL;                                                  \
                                                                       \
void main(void)                                                        \
{                                                                      \
      gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;          \
                                                                       \
      PosVecL = vec3(gl_Vertex);                                       \
      SunVecL = normalize(vec3(                                        \
         gl_ModelViewMatrixInverse*gl_LightSource[0].position));       \
}                                                                      \
"};

/**********************************************************************/
/*  Atmo Fragment Shader                                              */

GLchar AtmoFragText[] = {"                                             \
                                                                       \
uniform float Alt;                                                     \
uniform float MaxHt;                                                   \
uniform vec3 GasColor;                                                 \
uniform vec3 DustColor;                                                \
uniform float WorldRadius;                                             \
varying vec3 PosVecL;                                                  \
varying vec3 SunVecL;                                                  \
                                                                       \
void main(void)                                                        \
{                                                                      \
      float Ra = WorldRadius + Alt;                                    \
      vec3 RelDir = normalize(PosVecL - vec3(0.0,0.0,Alt));            \
      float ZenAng = acos(RelDir[2]);                                  \
      float HorZenAng = 3.14159-asin(WorldRadius/Ra);                  \
      float SunAng = acos(SunVecL[2]);                                 \
                                                                       \
      float fz = 1.2*sqrt(1.0-Alt/MaxHt);                              \
      float fg = 0.5+0.5*ZenAng/HorZenAng;                             \
      float fd = 0.1+0.5*pow(ZenAng/HorZenAng,4.0*(1.0+Alt/MaxHt));    \
      float fs = clamp(1.0+10.0*(HorZenAng-SunAng),0.0,1.0);           \
      vec3 SunColor = clamp(5.0E3*(dot(RelDir,SunVecL) - 0.99985),0.0,1.0) \
         *(vec3(1.0,1.0,0.9)-GasColor);                            \
                                                                       \
      gl_FragColor = vec4(fg*GasColor+fd*DustColor+SunColor,   \
                          fz*fs);                                      \
}                                                                      \
"};
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/*  Body Vertex Shader                                                */

GLchar BodyVtxText[] = {"                                              \
                                                                       \
uniform mat3 CNE;                                                      \
uniform mat4 ShadowMatrix;                                             \
varying mat3 CEB;                                                      \
varying vec3 PosVecB;                                                  \
varying vec3 LightVecE;                                                \
varying vec3 NormalVecE;                                               \
varying vec3 EyeVecE;                                                  \
varying vec3 NormalVecN;                                               \
varying vec3 EyeVecN;                                                  \
                                                                       \
varying vec2 ColorTexCoord;                                            \
varying vec4 ShadowCoord;                                              \
                                                                       \
void main(void)                                                        \
{                                                                      \
      gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;          \
      PosVecB = vec3(gl_Vertex);                                       \
      LightVecE = normalize(vec3(gl_LightSource[0].position));         \
      EyeVecE = -normalize(vec3(gl_ModelViewMatrix * gl_Vertex));      \
      EyeVecN = CNE*EyeVecE;                                           \
      CEB = gl_NormalMatrix;                                           \
      NormalVecE = normalize(CEB*gl_Normal);                           \
      NormalVecN = normalize(CNE*NormalVecE);                          \
                                                                       \
      ColorTexCoord = gl_MultiTexCoord0.st;                            \
      ShadowCoord = ShadowMatrix*gl_Vertex;                            \
      ShadowCoord = ShadowCoord/ShadowCoord.w;                         \
                                                                       \
}                                                                      \
"};

/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/*  Body Fragment Shader                                              */

GLchar BodyFragText[] = {"                                             \
                                                                       \
varying mat3 CEB;                                                      \
varying vec3 PosVecB;                                                  \
varying vec3 LightVecE;                                                \
varying vec3 NormalVecE;                                               \
varying vec3 EyeVecE;                                                  \
varying vec3 NormalVecN;                                               \
varying vec3 EyeVecN;                                                  \
                                                                       \
varying vec2 ColorTexCoord;                                            \
varying vec4 ShadowCoord;                                              \
                                                                       \
uniform sampler2D ColorTexture;                                        \
uniform sampler2D BumpTexture;                                         \
uniform samplerCube EnvironmentMap;                                    \
uniform sampler3D NoiseTexture;                                        \
uniform sampler1D SpectrumTexture;                                     \
uniform sampler2DShadow ShadowMap;                                     \
uniform vec4 NoiseGain;                                                \
uniform float NoiseBias;                                               \
uniform float NoiseScale;                                              \
uniform vec3 NoiseAxis;                                                \
uniform int  NoiseType;                                                \
uniform bool ColorTexEnabled;                                          \
uniform bool BumpTexEnabled;                                           \
uniform bool ReflectEnabled;                                           \
uniform bool NoiseColEnabled;                                          \
uniform bool NoiseBumpEnabled;                                         \
uniform bool ShadowsEnabled;                                           \
                                                                       \
/*********************************************************************/\
float MoaiVoronoi(vec3 Pos)                                            \
{                                                                      \
      int Ncell = 20;                                                  \
                                                                       \
      vec3 Cell[20];                                                   \
      Cell[ 0] = vec3(  -0.899240,   0.329625,  -0.551936);            \
      Cell[ 1] = vec3(  -0.388832,  -1.401045,  -0.951608);            \
      Cell[ 2] = vec3(   1.454074,  -0.140564,  -0.061765);            \
      Cell[ 3] = vec3(   0.887226,  -0.219726,   1.626191);            \
      Cell[ 4] = vec3(  -1.337870,   1.447301,   1.037350);            \
      Cell[ 5] = vec3(   1.451972,   0.683331,  -1.685818);            \
      Cell[ 6] = vec3(   2.355312,   0.255011,  -1.416038);            \
      Cell[ 7] = vec3(  -1.422909,  -0.486901,  -1.757204);            \
      Cell[ 8] = vec3(   1.679161,  -2.179792,  -0.873250);            \
      Cell[ 9] = vec3(  -2.154019,   2.272110,   0.572772);            \
      Cell[10] = vec3(  -0.861144,  -2.057742,  -2.175723);            \
      Cell[11] = vec3(   2.414222,  -0.447044,  -1.538406);            \
      Cell[12] = vec3(  -0.541811,  -0.945616,   2.172256);            \
      Cell[13] = vec3(   1.065633,  -1.323453,   1.121513);            \
      Cell[14] = vec3(  -0.593085,  -0.814691,   0.608026);            \
      Cell[15] = vec3(   0.187492,  -1.209283,   1.236455);            \
      Cell[16] = vec3(  -0.680762,  -1.636144,   0.542692);            \
      Cell[17] = vec3(  -0.868446,  -1.106143,  -2.207942);            \
      Cell[18] = vec3(   0.064421,  -0.050012,   0.660259);            \
      Cell[19] = vec3(   1.836757,  -1.320785,   1.907873);            \
                                                                       \
      float F1;                                                        \
      float F2;                                                        \
      float D;                                                         \
                                                                       \
      /* Add noise to P */                                             \
      vec4 V = texture3D(NoiseTexture,Pos);                            \
      float f = dot(NoiseGain,V) + NoiseBias;                          \
      vec3 P = Pos + 0.08*vec3(V.x);                                   \
                                                                       \
      /* Find distances to Cell centers */                             \
      F1 = 1000.0;                                                     \
      F2 = 1000.0;                                                     \
      for(int i=0;i<Ncell;i++) {                                       \
         D = distance(P,Cell[i]);                                      \
         if (D < F1) {                                                 \
            F2 = F1;                                                   \
            F1 = D;                                                    \
         }                                                             \
         else if (D < F2) {                                            \
            F2 = D;                                                    \
         }                                                             \
      }                                                                \
                                                                       \
      return(F2-F1+f);                                                 \
}                                                                      \
/*********************************************************************/\
vec4 NoiseCol(vec3 Pos)                                                \
{                                                                      \
      vec4 V = texture3D(NoiseTexture,Pos/NoiseScale);                 \
                                                                       \
      float f = dot(NoiseGain,V) + NoiseBias;                          \
                                                                       \
      if (NoiseType == 1) f = abs(f);                                  \
      if (NoiseType == 2) f = f*f;                                     \
      if (NoiseType == 3) {                                            \
         f = cos(dot(Pos,NoiseAxis) + f)*0.5+0.5;                      \
      }                                                                \
      if (NoiseType == 4) {                                            \
         f = cos(dot(Pos,NoiseAxis) + f)*0.5+0.5;                      \
         f = f*f;                                                      \
      }                                                                \
      if (NoiseType == 5) {                                            \
         f = MoaiVoronoi(Pos);                                         \
      }                                                                \
                                                                       \
      return(texture1D(SpectrumTexture,f));                            \
}                                                                      \
/*********************************************************************/\
vec3 NoiseBump(vec3 Pos)                                               \
{                                                                      \
      vec4 V1 = texture3D(NoiseTexture,Pos+vec3(0.2,0.2,0.0));         \
      vec4 V2 = texture3D(NoiseTexture,Pos+vec3(0.0,0.2,0.2));         \
      vec4 V3 = texture3D(NoiseTexture,Pos+vec3(0.2,0.0,0.2));         \
                                                                       \
      return(normalize(NormalVecE + 0.5*vec3(                          \
         V1.r+0.5*V1.g-0.75,                                           \
         V2.r+0.5*V2.g-0.75,                                           \
         V3.r+0.5*V3.g-0.75)));                                        \
}                                                                      \
/*********************************************************************/\
float OneSampleShadowLookup(void)                                      \
{                                                                      \
      float InLight = 0.0;                                             \
      if (ShadowCoord.x <= 0.001) InLight = 1.0;                       \
      if (ShadowCoord.x >= 0.999) InLight = 1.0;                       \
      if (ShadowCoord.y <= 0.001) InLight = 1.0;                       \
      if (ShadowCoord.y >= 0.999) InLight = 1.0;                       \
      if(shadow2DProj(ShadowMap,ShadowCoord).x == 1.0) InLight = 1.0;  \
      return(InLight);                                                 \
}                                                                      \
/*********************************************************************/\
float FourSampleShadowLookup(void)                                     \
{                                                                      \
      float depth;                                                     \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(0.75,0.75,0.0,0.0)*2.0/2048.0).x;            \
      float InLight1 = (depth != 1.0 ? 0.0 : 0.25);                    \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(-0.75,0.75,0.0,0.0)*2.0/2048.0).x;           \
      float InLight2 = (depth != 1.0 ? 0.0 : 0.25);                    \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(0.75,-0.75,0.0,0.0)*2.0/2048.0).x;           \
      float InLight3 = (depth != 1.0 ? 0.0 : 0.25);                    \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(-0.75,-0.75,0.0,0.0)*2.0/2048.0).x;          \
      float InLight4 = (depth != 1.0 ? 0.0 : 0.25);                    \
                                                                       \
      return(InLight1+InLight2+InLight3+InLight4);                     \
}                                                                      \
/*********************************************************************/\
float FiveSampleShadowLookup(void)                                     \
{                                                                      \
      float depth;                                                     \
                                                                       \
      depth = shadow2DProj(ShadowMap,ShadowCoord).x;                   \
      float InLight1 = (depth != 1.0 ? 0.0 : 0.2);                     \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(0.5,0.5,0.0,0.0)/2048.0).x;                  \
      float InLight2 = (depth != 1.0 ? 0.0 : 0.2);                     \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(-0.5,0.5,0.0,0.0)/2048.0).x;                 \
      float InLight3 = (depth != 1.0 ? 0.0 : 0.2);                     \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(-0.5,0.5,0.0,0.0)/2048.0).x;                 \
      float InLight4 = (depth != 1.0 ? 0.0 : 0.2);                     \
                                                                       \
      depth = shadow2DProj(ShadowMap,                                  \
         ShadowCoord+vec4(-0.5,-0.5,0.0,0.0)/2048.0).x;                \
      float InLight5 = (depth != 1.0 ? 0.0 : 0.2);                     \
                                                                       \
      return(InLight1+InLight2+InLight3+InLight4+InLight5);            \
}                                                                      \
/*********************************************************************/\
void main(void)                                                        \
{                                                                      \
                                                                       \
      vec4 TexColor = vec4(1.0);                                       \
      float InLight = 1.0;                                             \
      float DiffIllum = 0.0;                                           \
      float SpecIllum = 0.0;                                           \
      float NoL,EoR;                                                   \
                                                                       \
      vec3 NormE = NormalVecE;                                         \
                                                                       \
      if (NoiseBumpEnabled)                                            \
         NormE = normalize(NoiseBump(PosVecB));                        \
                                                                       \
      vec3 EyeReflectVecN = normalize(reflect(-EyeVecN,NormalVecN));   \
      vec3 LightReflectVecE = normalize(reflect(-LightVecE,NormE));    \
                                                                       \
      if (ColorTexEnabled)                                             \
         TexColor = texture2D(ColorTexture,ColorTexCoord);             \
                                                                       \
      if (BumpTexEnabled)                                              \
         NormE = normalize(CEB*normalize(vec3(                         \
               texture2D(BumpTexture,ColorTexCoord))-0.5));            \
                                                                       \
      if (ReflectEnabled)                                              \
         TexColor = textureCube(EnvironmentMap,EyeReflectVecN);        \
                                                                       \
      if (NoiseColEnabled)                                             \
         TexColor = NoiseCol(PosVecB);                                 \
                                                                       \
      if (ShadowsEnabled) {                                            \
         InLight = OneSampleShadowLookup();                            \
      }                                                                \
                                                                       \
      NoL = dot(NormE,LightVecE);                                      \
      if (InLight > 0.0 && NoL > 0.0) {                                \
         /* Diffuse Illumination */                                    \
         DiffIllum = clamp(NoL,0.0,1.0);                               \
         /* Specular Illumination */                                   \
         EoR = clamp(dot(EyeVecE,LightReflectVecE),0.0,1.0);           \
         SpecIllum = pow(EoR,gl_FrontMaterial.shininess);              \
      }                                                                \
                                                                       \
      if (ReflectEnabled) {                                            \
         DiffIllum = 1.0;                                              \
         SpecIllum = 0.0;                                              \
      }                                                                \
                                                                       \
/* .. Compute Colors */                                                \
      /* Ambient Color */                                              \
      gl_FragColor =                                                   \
           gl_LightModel.ambient*TexColor*gl_FrontMaterial.ambient     \
      /* Add Diffuse Color */                                          \
         + DiffIllum*gl_LightSource[0].diffuse*TexColor                \
            *gl_FrontMaterial.diffuse                                  \
      /* Add Specular Color */                                         \
         + SpecIllum*gl_LightSource[0].specular*                       \
            gl_FrontMaterial.specular;                                 \
}                                                                      \
"};


// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdShaders/Clouds3dNoise"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_NoiseSize("Noise Size", Float) = 1
		_CloudStrength("Cloud Strength", Float) = 1
		_TopTaper("Top Taper", Float) = 0
		_BottomTaper("Bottom Taper", Float) = 0
		_CloudSpeed("Cloud Speed", Float) = 0
		_CloudFluctuations("Cloud Fluctuations", Float) = 0
		_ShadingPower("Shading Power", Float) = 2
		_CloudSoftness("Cloud Softness", Float) = 1
		_RimBoost("Rim Boost", Float) = 0
		_MiddaySSSPower("Midday SSS Power", Range( 0 , 100)) = 0
		_DistanceFade("Distance Fade", Float) = 1
		_SunriseSunsetSSSPower("SunriseSunset SSS Power", Range( 1 , 10)) = 0
		_SSSStrength("SSS Strength", Float) = 1
		_DepthFadeDistance("Depth Fade Distance", Float) = 1
		_MarchDistance("March Distance", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Overlay+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float4 vertexColor : COLOR;
			float eyeDepth;
			float4 screenPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _CloudSpeed;
		uniform float _CloudFluctuations;
		uniform float _NoiseSize;
		uniform float _CloudStrength;
		uniform float _TopTaper;
		uniform float _BottomTaper;
		uniform float _MarchDistance;
		uniform float _ShadingPower;
		uniform float _RimBoost;
		uniform float _SunriseSunsetSSSPower;
		uniform float _MiddaySSSPower;
		uniform float _SSSStrength;
		uniform float _CloudSoftness;
		uniform float _DistanceFade;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFadeDistance;
		uniform float _Cutoff = 0.5;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult31 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 break310 = ( appendResult31 + ( _Time.y * _CloudSpeed ) );
			float3 appendResult35 = (float3(break310.x , ( ase_worldPos.y + ( _Time.y * _CloudFluctuations ) ) , break310.y));
			float temp_output_115_0 = ( _NoiseSize * 0.1 );
			float simplePerlin3D2 = snoise( ( appendResult35 * temp_output_115_0 ) );
			float PrimaryNoise149 = simplePerlin3D2;
			float temp_output_214_0 = (-1.0 + (i.vertexColor.a - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float VerticalFalloff315 = ( _CloudStrength * saturate( pow( ( 1.0 - saturate( temp_output_214_0 ) ) , _TopTaper ) ) * saturate( pow( ( 1.0 - saturate( -temp_output_214_0 ) ) , _BottomTaper ) ) );
			float temp_output_12_0 = ( PrimaryNoise149 * VerticalFalloff315 );
			float temp_output_107_0 = saturate( temp_output_12_0 );
			float cameraDepthFade171 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / _DistanceFade);
			float DistanceFade176 = saturate( ( 1.0 - cameraDepthFade171 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth286 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth286 = abs( ( screenDepth286 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) );
			c.rgb = 0;
			c.a = saturate( ( pow( temp_output_107_0 , _CloudSoftness ) * DistanceFade176 * saturate( distanceDepth286 ) ) );
			clip( ( temp_output_107_0 * DistanceFade176 ) - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldPos = i.worldPos;
			float2 appendResult31 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 break310 = ( appendResult31 + ( _Time.y * _CloudSpeed ) );
			float3 appendResult35 = (float3(break310.x , ( ase_worldPos.y + ( _Time.y * _CloudFluctuations ) ) , break310.y));
			float temp_output_115_0 = ( _NoiseSize * 0.1 );
			float simplePerlin3D2 = snoise( ( appendResult35 * temp_output_115_0 ) );
			float PrimaryNoise149 = simplePerlin3D2;
			float temp_output_214_0 = (-1.0 + (i.vertexColor.a - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float VerticalFalloff315 = ( _CloudStrength * saturate( pow( ( 1.0 - saturate( temp_output_214_0 ) ) , _TopTaper ) ) * saturate( pow( ( 1.0 - saturate( -temp_output_214_0 ) ) , _BottomTaper ) ) );
			float temp_output_12_0 = ( PrimaryNoise149 * VerticalFalloff315 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float simplePerlin3D76 = snoise( ( ( ( ase_worldlightDir * _MarchDistance ) + appendResult35 ) * temp_output_115_0 ) );
			float LightOffsetNoise150 = simplePerlin3D76;
			float dotResult234 = dot( float3(0,1,0) , ase_worldlightDir );
			float WhatsUpDot271 = dotResult234;
			float lerpResult298 = lerp( saturate( ( temp_output_12_0 - ( LightOffsetNoise150 * VerticalFalloff315 ) ) ) , ( i.vertexColor.a * 0.2 ) , saturate( WhatsUpDot271 ));
			float4 lerpResult229 = lerp( unity_AmbientGround , unity_AmbientSky , i.vertexColor.a);
			float4 Ambient220 = lerpResult229;
			float RimMas262 = lerpResult298;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult239 = dot( ase_worldViewDir , -ase_worldlightDir );
			float temp_output_240_0 = saturate( WhatsUpDot271 );
			float lerpResult242 = lerp( _SunriseSunsetSSSPower , _MiddaySSSPower , temp_output_240_0);
			float temp_output_247_0 = pow( saturate( dotResult239 ) , lerpResult242 );
			float4 SubsurfaceScattering155 = ( ( ( ( RimMas262 * _RimBoost ) * ase_lightColor * temp_output_247_0 ) + ( _SSSStrength * temp_output_247_0 * unity_AmbientSky * ( 1.0 - temp_output_240_0 ) ) ) * saturate( ( 15.0 * ( WhatsUpDot271 + 0.075 ) ) ) );
			o.Emission = ( float4( ( ase_lightColor.rgb * ase_lightColor.a * pow( lerpResult298 , _ShadingPower ) ) , 0.0 ) + Ambient220 + SubsurfaceScattering155 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float1 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.x = customInputData.eyeDepth;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.eyeDepth = IN.customPack1.x;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
1920;0;1920;1019;2984.503;323.9496;1.3;False;False
Node;AmplifyShaderEditor.CommentaryNode;319;-4161.206,1540.173;Inherit;False;1951.858;725.0492;;20;263;315;216;215;229;220;214;210;207;205;208;204;211;212;213;206;16;209;14;159;Vertical Falloff and Taper;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;157;-3991.551,-6.206512;Inherit;False;2103.639;596.2936;;24;149;150;290;31;33;313;41;309;312;2;76;6;77;115;75;114;7;289;35;308;310;37;30;4;3d Noise Generator;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-3966.051,439.9759;Float;False;Property;_CloudSpeed;Cloud Speed;5;0;Create;True;0;0;False;0;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;4;-3900.552,172.5433;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;33;-3958.481,347.1621;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;159;-4085.432,1688.705;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;309;-3733.362,325.5722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-3649.794,176.2224;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;313;-3965.748,513.6096;Float;False;Property;_CloudFluctuations;Cloud Fluctuations;6;0;Create;True;0;0;False;0;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;214;-3780.74,1778.72;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;312;-3577.734,482.5258;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;207;-3531.732,1837.638;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-3474.024,199.2858;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;205;-3375.854,1847.872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;210;-3542.478,1724.743;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;308;-3551.121,375.8782;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;37;-3929.698,30.55391;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;310;-3326.759,210.3416;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;290;-3309.772,113.3261;Float;False;Property;_MarchDistance;March Distance;16;0;Create;True;0;0;False;0;1;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-3380.721,1616.287;Float;False;Property;_TopTaper;Top Taper;3;0;Create;True;0;0;False;0;0;0.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3240.298,1939.265;Float;False;Property;_BottomTaper;Bottom Taper;4;0;Create;True;0;0;False;0;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-3371.854,382.1315;Float;False;Property;_NoiseSize;Noise Size;1;0;Create;True;0;0;False;0;1;2.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-3363.872,475.087;Float;False;Constant;_Float1;Float 1;15;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;204;-3378.82,1721.478;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;208;-3219.372,1841.127;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;-3074.732,246.8649;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-3049.517,57.78378;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-2861.227,53.05945;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;206;-3030.067,1841.678;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;211;-3189.405,1688.09;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-3099.482,402.1639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2901.674,1590.173;Float;False;Property;_CloudStrength;Cloud Strength;2;0;Create;True;0;0;False;0;1;3.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-2828.375,350.5354;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;213;-3024.905,1695.357;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;209;-2855.631,1832.766;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-2736.553,184.8565;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;76;-2563.053,151.3169;Inherit;False;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-2630.33,1714.237;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;320;-4057.015,-561.3288;Inherit;False;787.8179;406.6011;;4;230;232;234;271;Up Vector Blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;2;-2558.311,321.8918;Inherit;False;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;-2453.348,1737.124;Float;False;VerticalFalloff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;230;-4007.015,-333.7277;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;232;-3968.614,-511.3288;Float;False;Constant;_Vector0;Vector 0;23;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;184;-1733.187,299.802;Inherit;False;240;131;;1;151;Offset Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;149;-2186.23,322.1987;Float;False;PrimaryNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;-2205.273,164.707;Float;False;LightOffsetNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;183;-1705.008,62.99119;Inherit;False;230;121;;1;148;Primary Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-1725.206,341.981;Inherit;False;150;LightOffsetNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;-1695.008,99.99118;Inherit;False;149;PrimaryNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;317;-1416.119,423.8118;Inherit;False;315;VerticalFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;234;-3695.014,-436.1278;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-1423.189,15.55486;Inherit;False;315;VerticalFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;288;-1178.365,362.1436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;271;-3512.198,-396.5162;Float;False;WhatsUpDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1181.381,118.284;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;322;-840.4142,-369.161;Inherit;False;2084.081;705.5499;;15;299;91;300;89;307;298;262;88;87;98;99;225;156;100;318;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;318;-589.7558,-319.161;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;-417.7629,-6.096672;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;-790.4142,-150.9817;Inherit;False;271;WhatsUpDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;231;-4511.959,767.7689;Inherit;False;2498.291;607.5538;;24;256;252;251;249;248;247;245;244;243;239;236;235;233;265;303;272;155;277;305;314;240;242;238;241;SubSurface Scattering;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;233;-4351.872,1190.459;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;300;-419.6298,-154.7158;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-350.4234,-251.5409;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;89;-213.5437,7.025847;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;298;105.7686,1.065267;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;236;-4110.412,1170.511;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;235;-4342.19,1037.701;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;314;-3580.067,820.748;Inherit;False;271;WhatsUpDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;175;-3981.039,2873.423;Inherit;False;985.3195;206.9106;;5;172;173;171;174;176;Distance Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;228.2701,109.4482;Float;False;RimMas;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;240;-3314.911,829.2823;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;239;-4035.948,997.3286;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-3906.347,915.7432;Float;False;Property;_MiddaySSSPower;Midday SSS Power;11;0;Create;True;0;0;False;0;0;18.3;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-3915.299,832.3354;Float;False;Property;_SunriseSunsetSSSPower;SunriseSunset SSS Power;13;0;Create;True;0;0;False;0;0;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;277;-2964.78,832.5954;Inherit;False;590.9036;219.5254;;3;276;274;275;Horizon Shadowing;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-4480.479,935.2476;Float;False;Property;_RimBoost;Rim Boost;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-4350.93,812.5656;Inherit;False;262;RimMas;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-3977.704,2953.991;Float;False;Property;_DistanceFade;Distance Fade;12;0;Create;True;0;0;False;0;1;76.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;244;-3904.793,998.3436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;242;-3374.001,910.5721;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;276;-2914.78,882.5956;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;303;-3419.641,1289.679;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;248;-3631.714,1218.171;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;-4081.273,869.4805;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;305;-3164.614,947.603;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;171;-3812.409,2931.452;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;247;-3661.283,1023.357;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;245;-3762.49,1141.777;Float;False;Property;_SSSStrength;SSS Strength;14;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;321;-389.2622,540.6412;Inherit;False;1117.417;644.7927;;10;177;107;280;281;287;286;306;282;283;168;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-2750.21,900.1035;Inherit;False;2;2;0;FLOAT;15;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;173;-3574.141,2932.058;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-3235.915,1034.315;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;249;-2948.702,1121.867;Inherit;False;4;4;0;FLOAT;1;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;287;-301.3499,1070.434;Float;False;Property;_DepthFadeDistance;Depth Fade Distance;15;0;Create;True;0;0;False;0;1;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;172;-3404.594,2928.09;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;215;-4102.069,2155.222;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;275;-2548.875,942.1208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;256;-2661.929,1089.583;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;216;-4111.206,2032.52;Inherit;False;unity_AmbientGround;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;280;-335.5435,864.0388;Float;False;Property;_CloudSoftness;Cloud Softness;9;0;Create;True;0;0;False;0;1;9.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;-2475.514,1086.105;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;373.4865,202.2212;Float;False;Property;_ShadingPower;Shading Power;7;0;Create;True;0;0;False;0;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;229;-3716.97,2047.825;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;107;-339.2622,696.8365;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;286;-32.15619,1059.221;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;-3260.584,2923.516;Float;False;DistanceFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;281;-52.07283,873.2629;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;306;234.7007,1066.1;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;220;-3484.7,2058.072;Float;False;Ambient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;71.10668,701.9079;Inherit;False;176;DistanceFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;98;491.4669,-93.97498;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;87;484.6725,39.62892;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;-2266.709,1070.343;Float;False;SubsurfaceScattering;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;612.6742,-233.3233;Inherit;False;220;Ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;764.5982,45.5907;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;663.0681,221.3889;Inherit;False;155;SubsurfaceScattering;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;282;397.8323,867.9359;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;167;-3992.578,2376.85;Inherit;False;773.8656;371.1309;;7;165;166;163;162;161;169;228;Glancing Angle Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;228;-3583.504,2439.214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;163;-3712.123,2502.111;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;169;-3560.565,2485.388;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;1088.667,-12.91645;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;161;-3976.274,2420.287;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;165;-3387.564,2464.85;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-3730.448,2627.771;Float;False;Property;_GlancingAngleFade;Glancing Angle Fade;8;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;283;553.1555,738.0123;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;162;-3964.725,2572.387;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;348.9261,590.6412;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1532.256,178.8817;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;EdShaders/Clouds3dNoise;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Overlay;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;1;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Spherical;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;309;0;33;0
WireConnection;309;1;41;0
WireConnection;31;0;4;1
WireConnection;31;1;4;3
WireConnection;214;0;159;4
WireConnection;312;0;33;0
WireConnection;312;1;313;0
WireConnection;207;0;214;0
WireConnection;30;0;31;0
WireConnection;30;1;309;0
WireConnection;205;0;207;0
WireConnection;210;0;214;0
WireConnection;308;0;4;2
WireConnection;308;1;312;0
WireConnection;310;0;30;0
WireConnection;204;0;210;0
WireConnection;208;0;205;0
WireConnection;35;0;310;0
WireConnection;35;1;308;0
WireConnection;35;2;310;1
WireConnection;289;0;37;0
WireConnection;289;1;290;0
WireConnection;75;0;289;0
WireConnection;75;1;35;0
WireConnection;206;0;208;0
WireConnection;206;1;16;0
WireConnection;211;0;204;0
WireConnection;211;1;212;0
WireConnection;115;0;7;0
WireConnection;115;1;114;0
WireConnection;6;0;35;0
WireConnection;6;1;115;0
WireConnection;213;0;211;0
WireConnection;209;0;206;0
WireConnection;77;0;75;0
WireConnection;77;1;115;0
WireConnection;76;0;77;0
WireConnection;263;0;14;0
WireConnection;263;1;213;0
WireConnection;263;2;209;0
WireConnection;2;0;6;0
WireConnection;315;0;263;0
WireConnection;149;0;2;0
WireConnection;150;0;76;0
WireConnection;234;0;232;0
WireConnection;234;1;230;0
WireConnection;288;0;151;0
WireConnection;288;1;317;0
WireConnection;271;0;234;0
WireConnection;12;0;148;0
WireConnection;12;1;316;0
WireConnection;91;0;12;0
WireConnection;91;1;288;0
WireConnection;300;0;299;0
WireConnection;307;0;318;4
WireConnection;89;0;91;0
WireConnection;298;0;89;0
WireConnection;298;1;307;0
WireConnection;298;2;300;0
WireConnection;236;0;233;0
WireConnection;262;0;298;0
WireConnection;240;0;314;0
WireConnection;239;0;235;0
WireConnection;239;1;236;0
WireConnection;244;0;239;0
WireConnection;242;0;241;0
WireConnection;242;1;238;0
WireConnection;242;2;240;0
WireConnection;276;0;314;0
WireConnection;252;0;243;0
WireConnection;252;1;251;0
WireConnection;305;0;240;0
WireConnection;171;0;174;0
WireConnection;247;0;244;0
WireConnection;247;1;242;0
WireConnection;274;1;276;0
WireConnection;173;0;171;0
WireConnection;265;0;252;0
WireConnection;265;1;248;0
WireConnection;265;2;247;0
WireConnection;249;0;245;0
WireConnection;249;1;247;0
WireConnection;249;2;303;0
WireConnection;249;3;305;0
WireConnection;172;0;173;0
WireConnection;275;0;274;0
WireConnection;256;0;265;0
WireConnection;256;1;249;0
WireConnection;272;0;256;0
WireConnection;272;1;275;0
WireConnection;229;0;216;0
WireConnection;229;1;215;0
WireConnection;229;2;159;4
WireConnection;107;0;12;0
WireConnection;286;0;287;0
WireConnection;176;0;172;0
WireConnection;281;0;107;0
WireConnection;281;1;280;0
WireConnection;306;0;286;0
WireConnection;220;0;229;0
WireConnection;87;0;298;0
WireConnection;87;1;88;0
WireConnection;155;0;272;0
WireConnection;99;0;98;1
WireConnection;99;1;98;2
WireConnection;99;2;87;0
WireConnection;282;0;281;0
WireConnection;282;1;177;0
WireConnection;282;2;306;0
WireConnection;228;0;163;0
WireConnection;163;0;161;0
WireConnection;163;1;162;0
WireConnection;169;0;228;0
WireConnection;169;1;166;0
WireConnection;100;0;99;0
WireConnection;100;1;225;0
WireConnection;100;2;156;0
WireConnection;165;0;169;0
WireConnection;283;0;282;0
WireConnection;168;0;107;0
WireConnection;168;1;177;0
WireConnection;0;2;100;0
WireConnection;0;9;283;0
WireConnection;0;10;168;0
ASEEND*/
//CHKSM=558CD7B2E076E3F65BB9B062A8965A3E0D752E1C
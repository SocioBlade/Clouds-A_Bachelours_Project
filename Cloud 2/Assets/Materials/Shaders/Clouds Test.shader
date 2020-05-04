// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Clouds Test"
{
	Properties
	{
		_NoiseSize1("Noise Size", Float) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_CloudStrength1("Cloud Strength", Float) = 1
		_TopTaper1("Top Taper", Float) = 0
		_BottomTaper1("Bottom Taper", Float) = 0
		_CloudSpeed1("Cloud Speed", Float) = 0
		_CloudFluctuations1("Cloud Fluctuations", Float) = 0
		_ShadingPower1("Shading Power", Float) = 2
		_CloudSoftness1("Cloud Softness", Float) = 1
		_RimBoost1("Rim Boost", Float) = 0
		_MiddaySSSPower1("Midday SSS Power", Range( 0 , 100)) = 0
		_DistanceFade1("Distance Fade", Float) = 1
		_SunriseSunsetSSSPower1("SunriseSunset SSS Power", Range( 1 , 10)) = 0
		_SSSStrength1("SSS Strength", Float) = 1
		_DepthFadeDistance1("Depth Fade Distance", Float) = 1
		_MarchDistance1("March Distance", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Overlay+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		struct Input
		{
			float3 worldPos;
			float4 vertexColor : COLOR;
			float eyeDepth;
			float4 screenPos;
		};

		uniform float _CloudSpeed1;
		uniform float _CloudFluctuations1;
		uniform float _NoiseSize1;
		uniform float _CloudStrength1;
		uniform float _TopTaper1;
		uniform float _BottomTaper1;
		uniform float _MarchDistance1;
		uniform float _ShadingPower1;
		uniform float _RimBoost1;
		uniform float _SunriseSunsetSSSPower1;
		uniform float _MiddaySSSPower1;
		uniform float _SSSStrength1;
		uniform float _CloudSoftness1;
		uniform float _DistanceFade1;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFadeDistance1;
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

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldPos = i.worldPos;
			float2 appendResult428 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 break432 = ( appendResult428 + ( _Time.y * _CloudSpeed1 ) );
			float3 appendResult436 = (float3(break432.x , ( ase_worldPos.y + ( _Time.y * _CloudFluctuations1 ) ) , break432.y));
			float temp_output_439_0 = ( _NoiseSize1 * 0.1 );
			float simplePerlin3D444 = snoise( ( appendResult436 * temp_output_439_0 ) );
			float PrimaryNoise445 = simplePerlin3D444;
			float temp_output_322_0 = (-1.0 + (i.vertexColor.a - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
			float VerticalFalloff338 = ( _CloudStrength1 * saturate( pow( ( 1.0 - saturate( temp_output_322_0 ) ) , _TopTaper1 ) ) * saturate( pow( ( 1.0 - saturate( -temp_output_322_0 ) ) , _BottomTaper1 ) ) );
			float temp_output_342_0 = ( PrimaryNoise445 * VerticalFalloff338 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float simplePerlin3D443 = snoise( ( ( ( ase_worldlightDir * _MarchDistance1 ) + appendResult436 ) * temp_output_439_0 ) );
			float LightOffsetNoise446 = simplePerlin3D443;
			float dotResult339 = dot( float3(0,1,0) , ase_worldlightDir );
			float WhatsUpDot343 = dotResult339;
			float lerpResult354 = lerp( saturate( ( temp_output_342_0 - ( LightOffsetNoise446 * VerticalFalloff338 ) ) ) , ( i.vertexColor.a * 0.2 ) , saturate( WhatsUpDot343 ));
			float4 lerpResult386 = lerp( unity_AmbientGround , unity_AmbientSky , i.vertexColor.a);
			float4 Ambient392 = lerpResult386;
			float RimMas356 = lerpResult354;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult360 = dot( ase_worldViewDir , -ase_worldlightDir );
			float temp_output_357_0 = saturate( WhatsUpDot343 );
			float lerpResult363 = lerp( _SunriseSunsetSSSPower1 , _MiddaySSSPower1 , temp_output_357_0);
			float temp_output_371_0 = pow( saturate( dotResult360 ) , lerpResult363 );
			float4 SubsurfaceScattering393 = ( ( ( ( RimMas356 * _RimBoost1 ) * ase_lightColor * temp_output_371_0 ) + ( _SSSStrength1 * temp_output_371_0 * unity_AmbientSky * ( 1.0 - temp_output_357_0 ) ) ) * saturate( ( 15.0 * ( WhatsUpDot343 + 0.075 ) ) ) );
			o.Emission = ( float4( ( ase_lightColor.rgb * ase_lightColor.a * pow( lerpResult354 , _ShadingPower1 ) ) , 0.0 ) + Ambient392 + SubsurfaceScattering393 ).rgb;
			float temp_output_387_0 = saturate( temp_output_342_0 );
			float cameraDepthFade370 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / _DistanceFade1);
			float DistanceFade388 = saturate( ( 1.0 - cameraDepthFade370 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth385 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth385 = abs( ( screenDepth385 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance1 ) );
			o.Alpha = saturate( ( pow( temp_output_387_0 , _CloudSoftness1 ) * DistanceFade388 * saturate( distanceDepth385 ) ) );
			clip( ( temp_output_387_0 * DistanceFade388 ) - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
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
0;725;2067;634;4197.757;3124.751;5.287357;True;False
Node;AmplifyShaderEditor.CommentaryNode;420;-2495.011,-516.9935;Inherit;False;1951.858;725.0492;;20;392;386;383;380;338;335;334;333;332;331;330;329;328;327;326;325;324;323;322;321;Vertical Falloff and Taper;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;422;-2325.356,-2063.373;Inherit;False;2103.639;596.2936;;24;446;445;444;443;442;441;440;439;438;437;436;435;434;433;432;431;430;429;428;427;426;425;424;423;3d Noise Generator;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;423;-2299.856,-1617.191;Float;False;Property;_CloudSpeed1;Cloud Speed;4;0;Create;True;0;0;False;0;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;425;-2234.357,-1884.623;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;321;-2419.237,-368.4615;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;424;-2292.286,-1710.004;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;-2067.167,-1731.594;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;322;-2114.545,-278.4465;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;428;-1983.599,-1880.944;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;427;-2299.553,-1543.557;Float;False;Property;_CloudFluctuations1;Cloud Fluctuations;5;0;Create;True;0;0;False;0;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;430;-1807.829,-1857.881;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;-1911.539,-1574.641;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;323;-1865.537,-219.5286;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;324;-1709.659,-209.2946;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;325;-1876.283,-332.4235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;434;-2263.503,-2026.613;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;433;-1643.577,-1943.84;Float;False;Property;_MarchDistance1;March Distance;15;0;Create;True;0;0;False;0;1;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;432;-1660.564,-1846.825;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;431;-1884.926,-1681.288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;326;-1712.625,-335.6885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;328;-1714.526,-440.8795;Float;False;Property;_TopTaper1;Top Taper;2;0;Create;True;0;0;False;0;0;0.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-1574.103,-117.9015;Float;False;Property;_BottomTaper1;Bottom Taper;3;0;Create;True;0;0;False;0;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;327;-1553.177,-216.0396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;436;-1408.537,-1810.302;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;437;-1697.677,-1582.079;Float;False;Constant;_Float2;Float 1;15;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;438;-1705.659,-1675.035;Float;False;Property;_NoiseSize1;Noise Size;0;0;Create;True;0;0;False;0;1;2.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;435;-1383.322,-1999.383;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-1433.287,-1655.003;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;440;-1195.032,-2004.107;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;330;-1523.21,-369.0765;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;331;-1363.872,-215.4885;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;-1162.18,-1706.631;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-1070.358,-1872.31;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;334;-1235.479,-466.9935;Float;False;Property;_CloudStrength1;Cloud Strength;1;0;Create;True;0;0;False;0;1;3.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;333;-1189.436,-224.4005;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;332;-1358.71,-361.8094;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;-964.135,-342.9294;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;417;-2390.82,-2618.495;Inherit;False;787.8179;406.6011;;4;343;339;337;336;Up Vector Blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;444;-892.116,-1735.275;Inherit;False;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;443;-896.8579,-1905.85;Inherit;False;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;418;-66.99194,-1757.365;Inherit;False;240;131;;1;448;Offset Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;338;-787.1528,-320.0425;Float;False;VerticalFalloff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;336;-2302.419,-2568.495;Float;False;Constant;_Vector1;Vector 0;23;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;-520.0349,-1734.968;Float;False;PrimaryNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;446;-539.0779,-1892.459;Float;False;LightOffsetNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;337;-2340.82,-2390.894;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;419;-38.81299,-1994.175;Inherit;False;230;121;;1;447;Primary Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;448;-59.01099,-1715.186;Inherit;False;446;LightOffsetNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;-28.81299,-1957.175;Inherit;False;445;PrimaryNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;340;243.0061,-2041.612;Inherit;False;338;VerticalFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;339;-2028.819,-2493.294;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;250.076,-1633.355;Inherit;False;338;VerticalFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;484.8141,-1938.883;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;343;-1846.003,-2453.683;Float;False;WhatsUpDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;344;487.8301,-1695.023;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;415;825.7809,-2426.328;Inherit;False;2084.081;705.5499;;13;408;401;398;395;390;356;354;351;349;348;347;346;345;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;347;1076.439,-2376.328;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;346;1248.432,-2063.263;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;875.7809,-2208.148;Inherit;False;343;WhatsUpDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;416;-2845.764,-1289.398;Inherit;False;2498.291;607.5538;;20;413;393;389;382;377;373;371;369;367;365;363;361;360;359;358;357;355;353;352;350;SubSurface Scattering;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;350;-2685.677,-866.7075;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;351;1452.651,-2050.141;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;348;1315.772,-2308.708;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;349;1246.565,-2211.882;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;352;-2444.217,-886.6555;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;355;-1913.872,-1236.418;Inherit;False;343;WhatsUpDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;354;1771.964,-2056.101;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;353;-2675.995,-1019.465;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;358;-2249.104,-1224.831;Float;False;Property;_SunriseSunsetSSSPower1;SunriseSunset SSS Power;12;0;Create;True;0;0;False;0;0;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-2240.152,-1141.423;Float;False;Property;_MiddaySSSPower1;Midday SSS Power;10;0;Create;True;0;0;False;0;0;18.3;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;360;-2369.753,-1059.838;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;414;-2314.844,816.2566;Inherit;False;985.3195;206.9106;;5;388;379;375;370;362;Distance Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;1894.465,-1947.718;Float;False;RimMas;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;357;-1648.716,-1227.884;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;361;-2684.735,-1244.601;Inherit;False;356;RimMas;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-2311.509,896.8245;Float;False;Property;_DistanceFade1;Distance Fade;11;0;Create;True;0;0;False;0;1;76.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;363;-1707.806,-1146.594;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;364;-2238.598,-1058.823;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-2814.284,-1121.919;Float;False;Property;_RimBoost1;Rim Boost;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;413;-1298.585,-1224.571;Inherit;False;590.9036;219.5254;;3;381;374;372;Horizon Shadowing;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-2096.295,-915.3895;Float;False;Property;_SSSStrength1;SSS Strength;13;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;368;-2415.078,-1187.686;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;371;-1995.088,-1033.81;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;369;-1498.419,-1109.563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;367;-1965.519,-838.9955;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;366;-1753.446,-767.4875;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.CameraDepthFade;370;-2146.214,874.2854;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;372;-1248.585,-1174.571;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;412;1276.933,-1516.525;Inherit;False;1117.417;644.7927;;10;403;402;399;396;394;391;387;385;384;378;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;-1282.507,-935.2996;Inherit;False;4;4;0;FLOAT;1;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;-1569.72,-1022.852;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;375;-1907.946,874.8916;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;374;-1084.015,-1157.063;Inherit;False;2;2;0;FLOAT;15;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;379;-1738.399,870.9236;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;381;-882.6799,-1115.046;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;382;-995.7339,-967.5835;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;383;-2445.011,-24.64648;Inherit;False;unity_AmbientGround;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;378;1364.845,-986.7325;Float;False;Property;_DepthFadeDistance1;Depth Fade Distance;14;0;Create;True;0;0;False;0;1;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;380;-2435.874,98.05542;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;390;2039.682,-1854.945;Float;False;Property;_ShadingPower1;Shading Power;6;0;Create;True;0;0;False;0;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;388;-1594.389,866.3496;Float;False;DistanceFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;1330.652,-1193.128;Float;False;Property;_CloudSoftness1;Cloud Softness;8;0;Create;True;0;0;False;0;1;9.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;-809.3188,-971.0615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;385;1634.039,-997.9456;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;386;-2050.775,-9.341553;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;387;1326.933,-1360.33;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;391;1614.122,-1183.904;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;392;-1818.505,0.9055176;Float;False;Ambient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;393;-600.5139,-986.8235;Float;False;SubsurfaceScattering;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;394;1737.302,-1355.259;Inherit;False;388;DistanceFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;395;2150.868,-2017.538;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;396;1900.896,-991.0665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;397;2157.662,-2151.142;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;2430.793,-2011.576;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;400;2278.869,-2290.49;Inherit;False;392;Ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;2064.027,-1189.231;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;421;-2326.383,319.6836;Inherit;False;773.8656;371.1309;;6;411;409;407;406;405;404;Glancing Angle Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;2329.263,-1835.778;Inherit;False;393;SubsurfaceScattering;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;411;-2045.928,444.9446;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;410;-1894.37,428.2214;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;131.5394,3923.77;Inherit;True;Property;_CircularMask;CircularMask;2;0;Create;True;0;0;False;0;-1;None;c49ab7190c3872a4498395ef114cd70f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;408;2754.862,-2070.083;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;280;-4238.423,-1281.204;Inherit;False;InstancedProperty;_NoiseSize;Noise Size;8;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-4378.332,-1466.584;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;275;-4665.677,-1465.361;Inherit;False;InstancedProperty;_MarchDistance;March Distance;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;281;-5121.679,-1004.643;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;282;-5144.872,-1371.831;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;287;-5271.291,-1081.94;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-5413.008,-1418.431;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;284;-5671.54,-1531.105;Inherit;False;InstancedProperty;_CloudFluctuations;Cloud Fluctuations;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;288;-5460.276,-1121.616;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;279;-4321.564,-1317.87;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;False;0;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;-5442.732,-943.3775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;289;-5771.334,-1157.084;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;285;-5697.719,-1241.116;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-5748.168,-924.5655;Inherit;False;InstancedProperty;_CloudSpeed;Cloud Speed;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;274;-4674.887,-1623.592;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;277;-4784.471,-1226.291;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;-3910.475,-1418.641;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;272;-4141.872,-1466.583;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;31;-3536.184,-1447.916;Inherit;True;Property;_NoiseTexture;Noise Texture;3;0;Create;True;0;0;False;0;-1;None;0071966237b5f0149a4395ab56a935c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;121;-3538.848,-1093.382;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;-1;None;0071966237b5f0149a4395ab56a935c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;276;-3914.53,-1063.708;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;136;-3794.896,-1279.444;Inherit;True;Property;_CloudTexture;CloudTexture;4;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;-4066.645,-1237.017;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;2015.121,-1466.525;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;403;2219.351,-1319.154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;404;-2064.253,570.6045;Float;False;Property;_GlancingAngleFade1;Glancing Angle Fade;7;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;405;-2298.53,515.2205;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;406;-1721.369,407.6836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;407;-2310.079,363.1206;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;409;-1917.309,382.0476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3149.264,-1813.005;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Clouds Test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Overlay;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;426;0;424;0
WireConnection;426;1;423;0
WireConnection;322;0;321;4
WireConnection;428;0;425;1
WireConnection;428;1;425;3
WireConnection;430;0;428;0
WireConnection;430;1;426;0
WireConnection;429;0;424;0
WireConnection;429;1;427;0
WireConnection;323;0;322;0
WireConnection;324;0;323;0
WireConnection;325;0;322;0
WireConnection;432;0;430;0
WireConnection;431;0;425;2
WireConnection;431;1;429;0
WireConnection;326;0;325;0
WireConnection;327;0;324;0
WireConnection;436;0;432;0
WireConnection;436;1;431;0
WireConnection;436;2;432;1
WireConnection;435;0;434;0
WireConnection;435;1;433;0
WireConnection;439;0;438;0
WireConnection;439;1;437;0
WireConnection;440;0;435;0
WireConnection;440;1;436;0
WireConnection;330;0;326;0
WireConnection;330;1;328;0
WireConnection;331;0;327;0
WireConnection;331;1;329;0
WireConnection;441;0;436;0
WireConnection;441;1;439;0
WireConnection;442;0;440;0
WireConnection;442;1;439;0
WireConnection;333;0;331;0
WireConnection;332;0;330;0
WireConnection;335;0;334;0
WireConnection;335;1;332;0
WireConnection;335;2;333;0
WireConnection;444;0;441;0
WireConnection;443;0;442;0
WireConnection;338;0;335;0
WireConnection;445;0;444;0
WireConnection;446;0;443;0
WireConnection;339;0;336;0
WireConnection;339;1;337;0
WireConnection;342;0;447;0
WireConnection;342;1;340;0
WireConnection;343;0;339;0
WireConnection;344;0;448;0
WireConnection;344;1;341;0
WireConnection;346;0;342;0
WireConnection;346;1;344;0
WireConnection;351;0;346;0
WireConnection;348;0;347;4
WireConnection;349;0;345;0
WireConnection;352;0;350;0
WireConnection;354;0;351;0
WireConnection;354;1;348;0
WireConnection;354;2;349;0
WireConnection;360;0;353;0
WireConnection;360;1;352;0
WireConnection;356;0;354;0
WireConnection;357;0;355;0
WireConnection;363;0;358;0
WireConnection;363;1;359;0
WireConnection;363;2;357;0
WireConnection;364;0;360;0
WireConnection;368;0;361;0
WireConnection;368;1;365;0
WireConnection;371;0;364;0
WireConnection;371;1;363;0
WireConnection;369;0;357;0
WireConnection;370;0;362;0
WireConnection;372;0;355;0
WireConnection;377;0;373;0
WireConnection;377;1;371;0
WireConnection;377;2;366;0
WireConnection;377;3;369;0
WireConnection;376;0;368;0
WireConnection;376;1;367;0
WireConnection;376;2;371;0
WireConnection;375;0;370;0
WireConnection;374;1;372;0
WireConnection;379;0;375;0
WireConnection;381;0;374;0
WireConnection;382;0;376;0
WireConnection;382;1;377;0
WireConnection;388;0;379;0
WireConnection;389;0;382;0
WireConnection;389;1;381;0
WireConnection;385;0;378;0
WireConnection;386;0;383;0
WireConnection;386;1;380;0
WireConnection;386;2;321;4
WireConnection;387;0;342;0
WireConnection;391;0;387;0
WireConnection;391;1;384;0
WireConnection;392;0;386;0
WireConnection;393;0;389;0
WireConnection;395;0;354;0
WireConnection;395;1;390;0
WireConnection;396;0;385;0
WireConnection;398;0;397;1
WireConnection;398;1;397;2
WireConnection;398;2;395;0
WireConnection;399;0;391;0
WireConnection;399;1;394;0
WireConnection;399;2;396;0
WireConnection;411;0;407;0
WireConnection;411;1;405;0
WireConnection;410;0;409;0
WireConnection;410;1;404;0
WireConnection;408;0;398;0
WireConnection;408;1;400;0
WireConnection;408;2;401;0
WireConnection;273;0;274;0
WireConnection;273;1;275;0
WireConnection;281;0;287;0
WireConnection;282;0;283;0
WireConnection;282;1;289;2
WireConnection;287;0;288;0
WireConnection;287;1;290;0
WireConnection;283;0;284;0
WireConnection;283;1;285;0
WireConnection;288;0;289;1
WireConnection;288;1;289;3
WireConnection;290;0;285;0
WireConnection;290;1;291;0
WireConnection;277;1;282;0
WireConnection;277;2;281;0
WireConnection;271;0;272;0
WireConnection;271;1;278;0
WireConnection;272;0;273;0
WireConnection;272;1;277;0
WireConnection;31;0;136;0
WireConnection;31;1;271;0
WireConnection;121;0;136;0
WireConnection;121;1;276;0
WireConnection;276;0;277;0
WireConnection;276;1;278;0
WireConnection;278;0;280;0
WireConnection;278;1;279;0
WireConnection;402;0;387;0
WireConnection;402;1;394;0
WireConnection;403;0;399;0
WireConnection;406;0;410;0
WireConnection;409;0;411;0
WireConnection;0;2;408;0
WireConnection;0;9;403;0
WireConnection;0;10;402;0
ASEEND*/
//CHKSM=01EFC06FA810E3D085B26C2B5D455553AC336CDE
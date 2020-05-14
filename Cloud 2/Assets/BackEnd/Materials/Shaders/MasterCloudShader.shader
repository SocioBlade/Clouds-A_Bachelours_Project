// Upgrade NOTE: upgraded instancing buffer 'MasterCloudShader' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MasterCloudShader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.44
		_CloudTexture("CloudTexture", 2D) = "white" {}
		_CloudpanSpeed("Cloud pan Speed", Float) = 0.2
		_midYValue("midYValue", Float) = 0
		_SunriseSunsetSSSPower("SunriseSunset SSS Power", Range( 1 , 10)) = 0
		_SSSStrength("SSS Strength", Float) = 0
		_cloudHeight("cloudHeight", Float) = 0
		_TaperPower("Taper Power", Float) = 0
		_BlendTweaker("Blend Tweaker", Range( 0 , 2)) = 0
		_CloudStrength("Cloud Strength", Float) = 0
		_BottomLightingMultiplier("Bottom Lighting Multiplier", Float) = 0
		_TopLightingMultiplier("Top Lighting Multiplier", Float) = 0
		_DestortSize("Destort Size", Float) = 1
		_NoiseSize("Noise Size", Float) = 1
		_MarchDistance("March Distance", Float) = 0
		_ShadingPower("Shading Power", Float) = 0
		_CloudSofness("Cloud Sofness", Range( 0 , 9)) = 0
		_DepthFadeDistance("Depth Fade Distance", Float) = 0
		_DistanceFade("Distance Fade", Float) = 0
		_RimMultiplier("Rim Multiplier", Float) = 0
		_CloudDestortSpeed("Cloud Destort Speed", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
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
			float3 viewDir;
			float4 screenPos;
			float eyeDepth;
		};

		uniform sampler2D _CloudTexture;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Cutoff = 0.44;

		UNITY_INSTANCING_BUFFER_START(MasterCloudShader)
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudpanSpeed)
#define _CloudpanSpeed_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudSofness)
#define _CloudSofness_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _SSSStrength)
#define _SSSStrength_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _SunriseSunsetSSSPower)
#define _SunriseSunsetSSSPower_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _RimMultiplier)
#define _RimMultiplier_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _TopLightingMultiplier)
#define _TopLightingMultiplier_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _BottomLightingMultiplier)
#define _BottomLightingMultiplier_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _BlendTweaker)
#define _BlendTweaker_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _DepthFadeDistance)
#define _DepthFadeDistance_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _ShadingPower)
#define _ShadingPower_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudStrength)
#define _CloudStrength_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _TaperPower)
#define _TaperPower_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _cloudHeight)
#define _cloudHeight_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _midYValue)
#define _midYValue_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _DestortSize)
#define _DestortSize_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudDestortSpeed)
#define _CloudDestortSpeed_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _NoiseSize)
#define _NoiseSize_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _MarchDistance)
#define _MarchDistance_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _DistanceFade)
#define _DistanceFade_arr MasterCloudShader
		UNITY_INSTANCING_BUFFER_END(MasterCloudShader)

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
			float2 appendResult2 = (float2(ase_worldPos.x , ase_worldPos.z));
			float _CloudpanSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudpanSpeed_arr, _CloudpanSpeed);
			float2 temp_cast_0 = (( _Time.y * _CloudpanSpeed_Instance )).xx;
			float2 temp_output_163_0 = ( appendResult2 - temp_cast_0 );
			float _NoiseSize_Instance = UNITY_ACCESS_INSTANCED_PROP(_NoiseSize_arr, _NoiseSize);
			float temp_output_4_0 = ( _NoiseSize_Instance * 0.01 );
			float PrimaryNoise103 = tex2D( _CloudTexture, ( temp_output_163_0 * temp_output_4_0 ) ).r;
			float _CloudDestortSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudDestortSpeed_arr, _CloudDestortSpeed);
			float temp_output_187_0 = ( _Time.y * _CloudDestortSpeed_Instance );
			float _DestortSize_Instance = UNITY_ACCESS_INSTANCED_PROP(_DestortSize_arr, _DestortSize);
			float temp_output_179_0 = ( _DestortSize_Instance * 0.01 );
			float cloudDestort174 = tex2D( _CloudTexture, ( ( appendResult2 + temp_output_187_0 ) * temp_output_179_0 ) ).r;
			float _midYValue_Instance = UNITY_ACCESS_INSTANCED_PROP(_midYValue_arr, _midYValue);
			float VerticalStep22 = ( _midYValue_Instance - ase_worldPos.y );
			float _cloudHeight_Instance = UNITY_ACCESS_INSTANCED_PROP(_cloudHeight_arr, _cloudHeight);
			float _TaperPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_TaperPower_arr, _TaperPower);
			float _CloudStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudStrength_arr, _CloudStrength);
			float VerticalFalloff33 = ( ( 1.0 - pow( saturate( ( abs( VerticalStep22 ) / ( _cloudHeight_Instance * 0.5 ) ) ) , _TaperPower_Instance ) ) * _CloudStrength_Instance );
			float temp_output_106_0 = ( PrimaryNoise103 * cloudDestort174 * VerticalFalloff33 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float _MarchDistance_Instance = UNITY_ACCESS_INSTANCED_PROP(_MarchDistance_arr, _MarchDistance);
			float3 temp_output_98_0 = ( ase_worldlightDir * _MarchDistance_Instance );
			float2 temp_cast_1 = (( _Time.y * _CloudpanSpeed_Instance )).xx;
			float LightOffsetNoise104 = tex2D( _CloudTexture, ( ( temp_output_98_0 + float3( temp_output_163_0 ,  0.0 ) ) * temp_output_4_0 ).xy ).r;
			float cloudLightDestort181 = tex2D( _CloudTexture, ( ( temp_output_98_0 + float3( ( appendResult2 + temp_output_187_0 ) ,  0.0 ) ) * temp_output_179_0 ).xy ).r;
			float dotResult85 = dot( float3(0,1,0) , ase_worldlightDir );
			float WhatsUpDot87 = dotResult85;
			float lerpResult111 = lerp( saturate( ( temp_output_106_0 - ( LightOffsetNoise104 * cloudLightDestort181 * VerticalFalloff33 ) ) ) , ( i.vertexColor.a * 0.0 ) , saturate( WhatsUpDot87 ));
			float _ShadingPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_ShadingPower_arr, _ShadingPower);
			float _BlendTweaker_Instance = UNITY_ACCESS_INSTANCED_PROP(_BlendTweaker_arr, _BlendTweaker);
			float temp_output_66_0 = saturate( ( ( ( 1.0 - ( ( VerticalStep22 - 0.5 ) * 2.0 ) ) * _BlendTweaker_Instance * VerticalStep22 ) - VerticalStep22 ) );
			float _BottomLightingMultiplier_Instance = UNITY_ACCESS_INSTANCED_PROP(_BottomLightingMultiplier_arr, _BottomLightingMultiplier);
			float _TopLightingMultiplier_Instance = UNITY_ACCESS_INSTANCED_PROP(_TopLightingMultiplier_arr, _TopLightingMultiplier);
			float4 AmbientLight75 = ( ( unity_AmbientGround * temp_output_66_0 * _BottomLightingMultiplier_Instance ) + ( unity_AmbientSky * ( 1.0 - temp_output_66_0 ) * _TopLightingMultiplier_Instance ) );
			float RimMass116 = lerpResult111;
			float _RimMultiplier_Instance = UNITY_ACCESS_INSTANCED_PROP(_RimMultiplier_arr, _RimMultiplier);
			float dotResult42 = dot( i.viewDir , -ase_worldlightDir );
			float _SunriseSunsetSSSPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_SunriseSunsetSSSPower_arr, _SunriseSunsetSSSPower);
			float temp_output_145_0 = saturate( WhatsUpDot87 );
			float lerpResult147 = lerp( _SunriseSunsetSSSPower_Instance , 0.0 , temp_output_145_0);
			float temp_output_46_0 = pow( saturate( dotResult42 ) , lerpResult147 );
			float _SSSStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_SSSStrength_arr, _SSSStrength);
			float4 SubSurfaceScattering54 = ( ( ( ( RimMass116 * _RimMultiplier_Instance ) * ase_lightColor * temp_output_46_0 ) + ( _SSSStrength_Instance * temp_output_46_0 * unity_AmbientSky * ( 1.0 - temp_output_145_0 ) ) ) * saturate( ( 15.0 * ( WhatsUpDot87 + 0.075 ) ) ) );
			o.Emission = ( float4( ( ase_lightColor.rgb * ase_lightColor.a * pow( lerpResult111 , _ShadingPower_Instance ) ) , 0.0 ) + AmbientLight75 + SubSurfaceScattering54 ).rgb;
			float temp_output_122_0 = saturate( temp_output_106_0 );
			float _CloudSofness_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudSofness_arr, _CloudSofness);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float _DepthFadeDistance_Instance = UNITY_ACCESS_INSTANCED_PROP(_DepthFadeDistance_arr, _DepthFadeDistance);
			float screenDepth129 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth129 = abs( ( screenDepth129 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance_Instance ) );
			float _DistanceFade_Instance = UNITY_ACCESS_INSTANCED_PROP(_DistanceFade_arr, _DistanceFade);
			float cameraDepthFade132 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / _DistanceFade_Instance);
			float DistanceFade136 = saturate( ( 1.0 - cameraDepthFade132 ) );
			o.Alpha = saturate( ( pow( temp_output_122_0 , _CloudSofness_Instance ) * saturate( distanceDepth129 ) * DistanceFade136 ) );
			clip( ( temp_output_122_0 * DistanceFade136 ) - _Cutoff );
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
				surfIN.viewDir = worldViewDir;
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
0;0;1920;1019;4346.151;1064.78;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;39;-3770.18,395.5199;Inherit;False;2011.4;425.87;;16;19;21;20;26;38;22;25;23;24;28;27;31;30;33;164;167;Vertical Falloff and taper;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;21;-3749.54,593.8386;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;19;-3720.18,471.5899;Float;False;InstancedProperty;_midYValue;midYValue;3;0;Create;True;0;0;False;0;0;24.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-3449.545,528.2798;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-3229.542,705.3901;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-3251.38,626.9203;Float;False;InstancedProperty;_cloudHeight;cloudHeight;6;0;Create;True;0;0;False;0;0;33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-3253.681,482.5199;Inherit;False;VerticalStep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-3685.09,88.00334;Inherit;False;InstancedProperty;_CloudpanSpeed;Cloud pan Speed;2;0;Create;True;0;0;False;0;0.2;0.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-3915.591,-35.10588;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2981.18,627.5204;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;23;-3045.879,498.6201;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1;-3679.77,-162.8714;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;186;-3871.65,-423.8805;Inherit;False;InstancedProperty;_CloudDestortSpeed;Cloud Destort Speed;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-3606.45,-442.0803;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-3352.958,-34.22149;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-3360.199,-469.0642;Inherit;False;InstancedProperty;_MarchDistance;March Distance;14;0;Create;True;0;0;False;0;0;2.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;2;-3493.059,-169.2705;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;97;-3480.156,-340.3441;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-2818.68,539.1201;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-3097.956,-339.216;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;163;-3102.199,-168.8828;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-3064.778,-614.489;Inherit;False;InstancedProperty;_DestortSize;Destort Size;12;0;Create;True;0;0;False;0;1;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2745.878,673.0201;Float;False;InstancedProperty;_TaperPower;Taper Power;7;0;Create;True;0;0;False;0;0;0.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-3083.176,66.16202;Inherit;False;InstancedProperty;_NoiseSize;Noise Size;13;0;Create;True;0;0;False;0;1;1.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;167;-2677.53,549.2923;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;182;-3087.788,-467.9421;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-2853.484,-629.201;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;-3102.782,-723.245;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-2865.382,9.850073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;183;-2879.791,-462.7421;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;27;-2524.881,562.52;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-2880.485,-300.2126;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-2640.59,-458.8422;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-2643.124,-299.5667;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;6;-2612.522,-192.6017;Inherit;True;Property;_CloudTexture;CloudTexture;1;0;Create;True;0;0;False;0;0071966237b5f0149a4395ab56a935c7;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-2605.738,9.246463;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;164;-2340.983,562.8109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-2522.984,-725.8451;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2349.381,663.9203;Float;False;InstancedProperty;_CloudStrength;Cloud Strength;9;0;Create;True;0;0;False;0;0;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;102;-2311.003,-325.5689;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;180;-2307.969,-527.671;Inherit;True;Property;_TextureSample3;Texture Sample 3;21;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;88;-1465.62,-952.505;Inherit;False;770.6001;438.4354;;4;84;85;87;86;Up Vector Blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2163.482,562.5198;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-2304.815,-120.0536;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;172;-2316.296,-767.9927;Inherit;True;Property;_TextureSample2;Texture Sample 2;20;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-1953.849,-73.23214;Inherit;False;PrimaryNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-1958.755,-268.1035;Inherit;False;LightOffsetNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;86;-1415.62,-697.0696;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1982.782,605.4203;Inherit;False;VerticalFalloff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;-1959.569,-434.071;Inherit;False;cloudLightDestort;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;84;-1345.764,-902.505;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-1981.917,-754.7586;Inherit;False;cloudDestort;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;85;-1086.718,-782.8697;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-1683.176,689.1637;Inherit;False;103;PrimaryNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-1684.075,820.4985;Inherit;False;174;cloudDestort;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;-3767.369,1581.167;Inherit;False;2369.532;655.7288;;18;57;58;59;64;60;63;61;65;66;69;68;67;74;75;70;72;73;71;Ambient Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-1682.347,560.4695;Inherit;False;33;VerticalFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-1722.291,226.3644;Inherit;False;181;cloudLightDestort;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-1673.247,352.4693;Inherit;False;104;LightOffsetNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;139;-1299.325,-172.7956;Inherit;False;1403.289;451.6956;;14;115;111;113;110;112;109;114;116;117;118;119;120;121;55;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1437.09,403.7184;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-3717.369,1968.192;Inherit;False;22;VerticalStep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-1428.677,705.1641;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-919.0203,-788.0695;Inherit;False;WhatsUpDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;58;-3520.249,1972.242;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;56;-3799.11,878.819;Inherit;False;2012.871;600.9873;;26;44;40;43;42;47;45;49;51;46;52;48;50;53;54;141;142;143;144;145;147;148;149;150;151;152;154;SubSurfaceScattering;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;109;-1228.047,-122.7956;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1249.325,60.21737;Inherit;False;87;WhatsUpDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;-1206.07,143.8999;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-1043.314,143.3256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1034.239,-27.20743;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-3335.249,1970.242;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;113;-1038.891,65.51394;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;44;-3784.476,1331.9;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;43;-3563.822,1331.9;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;40;-3785.219,1183.842;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;64;-3300.632,1638.305;Inherit;False;22;VerticalStep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;60;-3144.249,1930.242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;111;-840.6273,29.08436;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-3264.331,1809.368;Inherit;False;InstancedProperty;_BlendTweaker;Blend Tweaker;8;0;Create;True;0;0;False;0;0;0.07;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-2898.282,910.4269;Inherit;False;87;WhatsUpDot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-3419.576,992.4445;Inherit;False;Constant;_DaySSSPower;Day SSS Power;19;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-708.3697,160.8024;Inherit;False;RimMass;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;42;-3561.34,1220.178;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-2915.249,1816.242;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;137;-3752.543,2348.183;Inherit;False;1039.197;212.8792;;5;131;132;134;135;136;Distance Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-3422.915,908.4927;Float;False;InstancedProperty;_SunriseSunsetSSSPower;SunriseSunset SSS Power;4;0;Create;True;0;0;False;0;0;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;145;-2696.523,996.4595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-3702.543,2420.897;Inherit;False;InstancedProperty;_DistanceFade;Distance Fade;18;0;Create;True;0;0;False;0;0;2519;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;147;-3056.871,968.7855;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-3759.765,1047.878;Inherit;False;InstancedProperty;_RimMultiplier;Rim Multiplier;19;0;Create;True;0;0;False;0;0;6.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-3767.765,938.8782;Inherit;False;116;RimMass;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;-2752.632,1746.305;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-3361.676,1185.713;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;-2553.633,1749.305;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;49;-3058.094,1344.555;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-2267.441,929.3779;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;132;-3509.525,2402.062;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3075.361,1255.668;Float;False;InstancedProperty;_SSSStrength;SSS Strength;5;0;Create;True;0;0;False;0;0;1.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;46;-3073.344,1153.125;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;52;-2903.472,1408.196;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;154;-2523.374,1060.724;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-3481.232,1085.283;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2323.999,2120.894;Float;False;InstancedProperty;_TopLightingMultiplier;Top Lighting Multiplier;11;0;Create;True;0;0;False;0;0;3.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2557.253,1160.043;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;70;-2323.771,1940.143;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;134;-3256.353,2403.941;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;68;-2358.023,1631.167;Inherit;False;unity_AmbientGround;0;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;140;-1208.372,565.7242;Inherit;False;1146.238;464.5139;;10;122;124;123;125;126;127;128;129;130;138;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2363.055,1805.145;Float;False;InstancedProperty;_BottomLightingMultiplier;Bottom Lighting Multiplier;10;0;Create;True;0;0;False;0;0;28.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2732.679,1098.959;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;72;-2353.999,2031.895;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-2128.341,931.978;Inherit;False;2;2;0;FLOAT;15;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-2019.375,1909.046;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-2337.836,1150.818;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1158.372,913.8373;Float;False;InstancedProperty;_DepthFadeDistance;Depth Fade Distance;17;0;Create;True;0;0;False;0;0;59.82;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;135;-3101.493,2400.009;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;150;-1981.442,961.8779;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2045.023,1694.167;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;122;-1023.105,715.0984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-2145.241,1143.878;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-2937.347,2398.183;Inherit;False;DistanceFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;129;-910.4671,895.2383;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-1817.171,1799.919;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-783.9191,-66.25879;Float;False;InstancedProperty;_ShadingPower;Shading Power;15;0;Create;True;0;0;False;0;0;1.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1097.414,802.212;Float;False;InstancedProperty;_CloudSofness;Cloud Sofness;16;0;Create;True;0;0;False;0;0;4;0;9;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1995.239,1116.592;Inherit;False;SubSurfaceScattering;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;128;-634.3502,853.7079;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-1621.838,1807.521;Inherit;False;AmbientLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-660.3414,714.9226;Inherit;False;136;DistanceFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;120;-564.9192,-94.25882;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;123;-807.5501,759.8366;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;117;-565.7272,28.92262;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-318.9193,-18.25883;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-311.6867,113.6331;Inherit;False;54;SubSurfaceScattering;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-470.4067,759.8365;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-362.8044,-277.409;Inherit;False;75;AmbientLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-495.5275,615.7243;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;127;-227.1347,743.9709;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-49.03671,2.712522;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;268.7162,373.4058;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MasterCloudShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.44;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;19;0
WireConnection;20;1;21;2
WireConnection;22;0;20;0
WireConnection;25;0;26;0
WireConnection;25;1;38;0
WireConnection;23;0;22;0
WireConnection;187;0;7;0
WireConnection;187;1;186;0
WireConnection;89;0;7;0
WireConnection;89;1;8;0
WireConnection;2;0;1;1
WireConnection;2;1;1;3
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;98;0;97;0
WireConnection;98;1;100;0
WireConnection;163;0;2;0
WireConnection;163;1;89;0
WireConnection;167;0;24;0
WireConnection;182;0;2;0
WireConnection;182;1;187;0
WireConnection;179;0;178;0
WireConnection;176;0;2;0
WireConnection;176;1;187;0
WireConnection;4;0;96;0
WireConnection;183;0;98;0
WireConnection;183;1;182;0
WireConnection;27;0;167;0
WireConnection;27;1;28;0
WireConnection;99;0;98;0
WireConnection;99;1;163;0
WireConnection;184;0;183;0
WireConnection;184;1;179;0
WireConnection;101;0;99;0
WireConnection;101;1;4;0
WireConnection;155;0;163;0
WireConnection;155;1;4;0
WireConnection;164;0;27;0
WireConnection;177;0;176;0
WireConnection;177;1;179;0
WireConnection;102;0;6;0
WireConnection;102;1;101;0
WireConnection;180;0;6;0
WireConnection;180;1;184;0
WireConnection;30;0;164;0
WireConnection;30;1;31;0
WireConnection;5;0;6;0
WireConnection;5;1;155;0
WireConnection;172;0;6;0
WireConnection;172;1;177;0
WireConnection;103;0;5;1
WireConnection;104;0;102;1
WireConnection;33;0;30;0
WireConnection;181;0;180;1
WireConnection;174;0;172;1
WireConnection;85;0;84;0
WireConnection;85;1;86;0
WireConnection;36;0;170;0
WireConnection;36;1;185;0
WireConnection;36;2;171;0
WireConnection;106;0;107;0
WireConnection;106;1;175;0
WireConnection;106;2;171;0
WireConnection;87;0;85;0
WireConnection;58;0;57;0
WireConnection;114;0;106;0
WireConnection;114;1;36;0
WireConnection;115;0;114;0
WireConnection;110;0;109;4
WireConnection;59;0;58;0
WireConnection;113;0;112;0
WireConnection;43;0;44;0
WireConnection;60;0;59;0
WireConnection;111;0;115;0
WireConnection;111;1;110;0
WireConnection;111;2;113;0
WireConnection;116;0;111;0
WireConnection;42;0;40;0
WireConnection;42;1;43;0
WireConnection;61;0;60;0
WireConnection;61;1;63;0
WireConnection;61;2;64;0
WireConnection;145;0;144;0
WireConnection;147;0;47;0
WireConnection;147;1;148;0
WireConnection;147;2;145;0
WireConnection;65;0;61;0
WireConnection;65;1;64;0
WireConnection;45;0;42;0
WireConnection;66;0;65;0
WireConnection;152;0;144;0
WireConnection;132;0;131;0
WireConnection;46;0;45;0
WireConnection;46;1;147;0
WireConnection;154;0;145;0
WireConnection;142;0;143;0
WireConnection;142;1;141;0
WireConnection;50;0;51;0
WireConnection;50;1;46;0
WireConnection;50;2;52;0
WireConnection;50;3;154;0
WireConnection;70;0;66;0
WireConnection;134;0;132;0
WireConnection;48;0;142;0
WireConnection;48;1;49;0
WireConnection;48;2;46;0
WireConnection;151;1;152;0
WireConnection;71;0;72;0
WireConnection;71;1;70;0
WireConnection;71;2;73;0
WireConnection;53;0;48;0
WireConnection;53;1;50;0
WireConnection;135;0;134;0
WireConnection;150;0;151;0
WireConnection;67;0;68;0
WireConnection;67;1;66;0
WireConnection;67;2;69;0
WireConnection;122;0;106;0
WireConnection;149;0;53;0
WireConnection;149;1;150;0
WireConnection;136;0;135;0
WireConnection;129;0;130;0
WireConnection;74;0;67;0
WireConnection;74;1;71;0
WireConnection;54;0;149;0
WireConnection;128;0;129;0
WireConnection;75;0;74;0
WireConnection;123;0;122;0
WireConnection;123;1;124;0
WireConnection;117;0;111;0
WireConnection;117;1;118;0
WireConnection;119;0;120;1
WireConnection;119;1;120;2
WireConnection;119;2;117;0
WireConnection;126;0;123;0
WireConnection;126;1;128;0
WireConnection;126;2;138;0
WireConnection;125;0;122;0
WireConnection;125;1;138;0
WireConnection;127;0;126;0
WireConnection;121;0;119;0
WireConnection;121;1;76;0
WireConnection;121;2;55;0
WireConnection;0;2;121;0
WireConnection;0;9;127;0
WireConnection;0;10;125;0
ASEEND*/
//CHKSM=5ADB0CA879B1E8B4370955AE369A3D88B074017D
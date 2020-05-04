// Upgrade NOTE: upgraded instancing buffer 'MasterCloudShader' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MasterCloudShader"
{
	Properties
	{
		_CloudTexture("CloudTexture", 2D) = "white" {}
		_CloudpanSpeed("Cloud pan Speed", Float) = 0.2
		_CloudCutoff("Cloud Cutoff", Range( 0 , 1)) = 0.2
		_midYValue("midYValue", Float) = 0
		_cloudHeight("cloudHeight", Float) = 0
		_TaperPower("Taper Power", Float) = 0
		_CloudStrength("Cloud Strength", Float) = 0
		_SSSPower("SSS Power", Range( 1 , 10)) = 0
		_SSSStrength("SSS Strength", Float) = 0
		_BlendTweaker("Blend Tweaker", Range( 0 , 2)) = 0
		_BottomLightingMultiplier("Bottom Lighting Multiplier", Float) = 0
		_TopLightingMultiplier("Top Lighting Multiplier", Float) = 0
		_NoiseSize("Noise Size", Float) = 1
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
			float3 viewDir;
			float3 worldPos;
		};

		uniform sampler2D _CloudTexture;

		UNITY_INSTANCING_BUFFER_START(MasterCloudShader)
			UNITY_DEFINE_INSTANCED_PROP(float, _SSSPower)
#define _SSSPower_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _SSSStrength)
#define _SSSStrength_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _midYValue)
#define _midYValue_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _BlendTweaker)
#define _BlendTweaker_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _BottomLightingMultiplier)
#define _BottomLightingMultiplier_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _TopLightingMultiplier)
#define _TopLightingMultiplier_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _cloudHeight)
#define _cloudHeight_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _TaperPower)
#define _TaperPower_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudStrength)
#define _CloudStrength_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudpanSpeed)
#define _CloudpanSpeed_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _NoiseSize)
#define _NoiseSize_arr MasterCloudShader
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudCutoff)
#define _CloudCutoff_arr MasterCloudShader
		UNITY_INSTANCING_BUFFER_END(MasterCloudShader)

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult42 = dot( i.viewDir , -ase_worldlightDir );
			float _SSSPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_SSSPower_arr, _SSSPower);
			float temp_output_46_0 = pow( saturate( dotResult42 ) , _SSSPower_Instance );
			float _SSSStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_SSSStrength_arr, _SSSStrength);
			float4 SubSurfaceScattering54 = ( ( ase_lightColor * temp_output_46_0 ) + ( _SSSStrength_Instance * temp_output_46_0 * ase_lightColor * unity_AmbientSky ) );
			float _midYValue_Instance = UNITY_ACCESS_INSTANCED_PROP(_midYValue_arr, _midYValue);
			float VerticalStep22 = ( _midYValue_Instance - ase_worldPos.y );
			float _BlendTweaker_Instance = UNITY_ACCESS_INSTANCED_PROP(_BlendTweaker_arr, _BlendTweaker);
			float temp_output_66_0 = saturate( ( ( ( 1.0 - ( ( VerticalStep22 - 0.5 ) * 2.0 ) ) * _BlendTweaker_Instance * VerticalStep22 ) - VerticalStep22 ) );
			float _BottomLightingMultiplier_Instance = UNITY_ACCESS_INSTANCED_PROP(_BottomLightingMultiplier_arr, _BottomLightingMultiplier);
			float _TopLightingMultiplier_Instance = UNITY_ACCESS_INSTANCED_PROP(_TopLightingMultiplier_arr, _TopLightingMultiplier);
			float4 AmbientLight75 = ( ( unity_AmbientGround * temp_output_66_0 * _BottomLightingMultiplier_Instance ) + ( unity_AmbientSky * ( 1.0 - temp_output_66_0 ) * _TopLightingMultiplier_Instance ) );
			o.Emission = ( SubSurfaceScattering54 + AmbientLight75 ).rgb;
			float _cloudHeight_Instance = UNITY_ACCESS_INSTANCED_PROP(_cloudHeight_arr, _cloudHeight);
			float _TaperPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_TaperPower_arr, _TaperPower);
			float _CloudStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudStrength_arr, _CloudStrength);
			float VerticalFalloff33 = ( ( 1.0 - pow( ( abs( VerticalStep22 ) / ( _cloudHeight_Instance * 0.5 ) ) , _TaperPower_Instance ) ) * _CloudStrength_Instance );
			float2 appendResult2 = (float2(ase_worldPos.x , ase_worldPos.z));
			float _CloudpanSpeed_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudpanSpeed_arr, _CloudpanSpeed);
			float _NoiseSize_Instance = UNITY_ACCESS_INSTANCED_PROP(_NoiseSize_arr, _NoiseSize);
			float _CloudCutoff_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudCutoff_arr, _CloudCutoff);
			o.Alpha = saturate( pow( saturate( (0.0 + (( VerticalFalloff33 * tex2D( _CloudTexture, ( ( appendResult2 + ( _Time.y * _CloudpanSpeed_Instance ) ) * _NoiseSize_Instance ) ).r ) - _CloudCutoff_Instance) * (1.0 - 0.0) / (1.0 - _CloudCutoff_Instance)) ) , 1.0 ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float3 worldPos : TEXCOORD1;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
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
0;334;1550;665;3838.848;517.5071;1.181922;True;False
Node;AmplifyShaderEditor.CommentaryNode;39;-3266.469,366.4595;Inherit;False;2011.4;425.87;;15;19;21;20;26;38;22;25;23;24;28;27;31;37;30;33;Vertical Falloff and taper;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;21;-3212.834,554.2196;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;19;-3216.469,442.5295;Float;False;InstancedProperty;_midYValue;midYValue;4;0;Create;True;0;0;False;0;0;5.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-2949.834,517.2195;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;-3276.905,1611.877;Inherit;False;2369.532;655.7288;;18;57;58;59;64;60;63;61;65;66;69;68;67;74;75;70;72;73;71;Ambient Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-2717.97,416.4595;Float;False;VerticalStep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-3226.905,1998.902;Inherit;False;22;VerticalStep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2725.831,676.3298;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2747.669,597.8599;Float;False;InstancedProperty;_cloudHeight;cloudHeight;5;0;Create;True;0;0;False;0;0;2.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2477.469,598.46;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;23;-2476.168,503.5597;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;58;-3029.785,2002.952;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;10;-3283.378,-349.547;Inherit;False;1452.104;574.5667;Comment;13;1;2;3;4;5;6;7;8;35;89;96;97;98;Noise Getter;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-2844.785,2000.952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;56;-3277.801,893.4671;Inherit;False;2012.871;600.9873;;14;44;40;43;42;47;45;49;51;46;52;48;50;53;54;SubSurfaceScattering;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-2285.068,533.4597;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2242.167,643.9598;Float;False;InstancedProperty;_TaperPower;Taper Power;6;0;Create;True;0;0;False;0;0;1.71;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-3256.945,72.07883;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;44;-3223.777,1203.76;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;64;-2810.168,1669.015;Inherit;False;22;VerticalStep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-3257.117,142.0785;Inherit;False;InstancedProperty;_CloudpanSpeed;Cloud pan Speed;2;0;Create;True;0;0;False;0;0.2;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;60;-2653.785,1960.952;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1;-3258.297,-73.88083;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;27;-2021.168,533.4596;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2773.867,1840.078;Inherit;False;InstancedProperty;_BlendTweaker;Blend Tweaker;10;0;Create;True;0;0;False;0;0;1.37;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;40;-3227.801,1024.518;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-2424.785,1846.952;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;43;-3003.123,1203.76;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;37;-1837.276,536.277;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;2;-3059.586,9.720064;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-3067.014,116.4632;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1845.668,634.8599;Float;False;InstancedProperty;_CloudStrength;Cloud Strength;7;0;Create;True;0;0;False;0;0;0.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;42;-2816.822,1028.03;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;-2262.168,1777.015;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;3;-2905.341,9.160662;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2425.132,135.4393;Inherit;False;InstancedProperty;_NoiseSize;Noise Size;13;0;Create;True;0;0;False;0;1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1659.769,533.4595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-2645.056,1028.03;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;-2063.169,1780.015;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2666.198,943.4671;Float;False;InstancedProperty;_SSSPower;SSS Power;8;0;Create;True;0;0;False;0;0;1.06;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;6;-2348.575,-139.882;Inherit;True;Property;_CloudTexture;CloudTexture;1;0;Create;True;0;0;False;0;0071966237b5f0149a4395ab56a935c7;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-2259.43,54.39977;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1479.068,576.3599;Inherit;False;VerticalFalloff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;68;-1867.559,1661.877;Inherit;False;unity_AmbientGround;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-2018.122,-54.2998;Inherit;False;33;VerticalFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-2120.057,24.57578;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;70;-1833.307,1970.853;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-2580.313,1139.017;Float;False;InstancedProperty;_SSSStrength;SSS Strength;9;0;Create;True;0;0;False;0;0;-0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;49;-2495.752,1232.828;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;18;-1638.433,-17.57339;Inherit;False;1239.29;272.1124;Comment;6;12;11;13;15;14;16;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;46;-2370.229,1026.708;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1833.535,2151.605;Float;False;InstancedProperty;_TopLightingMultiplier;Top Lighting Multiplier;12;0;Create;True;0;0;False;0;0;1.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1860.759,1864.777;Float;False;InstancedProperty;_BottomLightingMultiplier;Bottom Lighting Multiplier;11;0;Create;True;0;0;False;0;0;-8.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;72;-1863.535,2062.606;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;52;-2388.728,1383.454;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1588.433,133.1763;Inherit;False;InstancedProperty;_CloudCutoff;Cloud Cutoff;3;0;Create;True;0;0;False;0;0.2;0.892;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1554.559,1724.877;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2055.763,1026.708;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2035.944,1174.691;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1528.911,1939.756;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1792.679,22.66624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1811.327,1086.166;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;11;-1274.429,47.53899;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-1326.706,1830.629;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1022.555,123.1014;Inherit;False;Constant;_CloudSoftness;Cloud Softness;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;13;-995.6882,42.50156;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-1131.373,1838.231;Inherit;False;AmbientLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1525.929,1059.74;Inherit;False;SubSurfaceScattering;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;14;-802.5843,32.42661;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;88;-3271.693,-879.6988;Inherit;False;770.6001;438.4354;;4;84;85;87;86;Up Vector Blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-729.2996,-139.8802;Inherit;False;75;AmbientLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-773.5759,-215.7026;Inherit;False;54;SubSurfaceScattering;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;85;-2892.791,-710.0635;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-2725.093,-715.2633;Inherit;False;WhatsUpDot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-489.1483,-159.9224;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;97;-3262.511,-275.1593;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;84;-3151.837,-829.6988;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;86;-3221.693,-624.2634;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;16;-564.143,66.00988;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2762.118,-257.4843;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-308.7913,-152.0526;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MasterCloudShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;19;0
WireConnection;20;1;21;2
WireConnection;22;0;20;0
WireConnection;25;0;26;0
WireConnection;25;1;38;0
WireConnection;23;0;22;0
WireConnection;58;0;57;0
WireConnection;59;0;58;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;60;0;59;0
WireConnection;27;0;24;0
WireConnection;27;1;28;0
WireConnection;61;0;60;0
WireConnection;61;1;63;0
WireConnection;61;2;64;0
WireConnection;43;0;44;0
WireConnection;37;0;27;0
WireConnection;2;0;1;1
WireConnection;2;1;1;3
WireConnection;89;0;7;0
WireConnection;89;1;8;0
WireConnection;42;0;40;0
WireConnection;42;1;43;0
WireConnection;65;0;61;0
WireConnection;65;1;64;0
WireConnection;3;0;2;0
WireConnection;3;1;89;0
WireConnection;30;0;37;0
WireConnection;30;1;31;0
WireConnection;45;0;42;0
WireConnection;66;0;65;0
WireConnection;4;0;3;0
WireConnection;4;1;96;0
WireConnection;33;0;30;0
WireConnection;5;0;6;0
WireConnection;5;1;4;0
WireConnection;70;0;66;0
WireConnection;46;0;45;0
WireConnection;46;1;47;0
WireConnection;67;0;68;0
WireConnection;67;1;66;0
WireConnection;67;2;69;0
WireConnection;48;0;49;0
WireConnection;48;1;46;0
WireConnection;50;0;51;0
WireConnection;50;1;46;0
WireConnection;50;2;49;0
WireConnection;50;3;52;0
WireConnection;71;0;72;0
WireConnection;71;1;70;0
WireConnection;71;2;73;0
WireConnection;36;0;35;0
WireConnection;36;1;5;1
WireConnection;53;0;48;0
WireConnection;53;1;50;0
WireConnection;11;0;36;0
WireConnection;11;1;12;0
WireConnection;74;0;67;0
WireConnection;74;1;71;0
WireConnection;13;0;11;0
WireConnection;75;0;74;0
WireConnection;54;0;53;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;85;0;84;0
WireConnection;85;1;86;0
WireConnection;87;0;85;0
WireConnection;77;0;55;0
WireConnection;77;1;76;0
WireConnection;16;0;14;0
WireConnection;98;0;97;0
WireConnection;0;2;77;0
WireConnection;0;9;16;0
ASEEND*/
//CHKSM=0BE06EA94979DD12985F90739EFE034419460EEE
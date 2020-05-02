// Upgrade NOTE: upgraded instancing buffer 'CloudsTest' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Clouds Test"
{
	Properties
	{
		_Cloudpanspeed("Cloud pan speed", Float) = 0.5
		_OffsetDistance("Offset Distance", Range( 0 , 1)) = 0.2
		_NoiseSplat("NoiseSplat", 2D) = "white" {}
		_NoiseTextureHigherSize("Noise Texture Higher Size", Range( 0 , 1.5)) = 0
		_DetailNoiseSize("Detail Noise Size", Range( 0 , 1.5)) = 0
		_CloudCutoff("Cloud Cutoff", Range( 0 , 1)) = 0
		_CloudSoftness("Cloud Softness", Range( 0 , 3)) = 0
		_midYValue("midYValue", Float) = 0
		_cloudHeight("cloudHeight", Float) = 0
		_TaperPower("Taper Power", Float) = 0
		_CircularMask("CircularMask", 2D) = "white" {}
		_VerticalFalloff("Vertical Falloff", Range( 0 , 0.5)) = 0.1762353
		_SSSPower("SSS Power", Range( 1 , 56)) = 0
		_CloudTexture("CloudTexture", 2D) = "white" {}
		_SSSStrength("SSS Strength", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _VerticalFalloff;
		uniform sampler2D _CloudTexture;
		uniform float _Cloudpanspeed;
		uniform float _NoiseTextureHigherSize;
		uniform float _DetailNoiseSize;
		uniform sampler2D _CircularMask;
		uniform sampler2D _NoiseSplat;

		UNITY_INSTANCING_BUFFER_START(CloudsTest)
			UNITY_DEFINE_INSTANCED_PROP(float4, _CircularMask_ST)
#define _CircularMask_ST_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float4, _NoiseSplat_ST)
#define _NoiseSplat_ST_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _midYValue)
#define _midYValue_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _cloudHeight)
#define _cloudHeight_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _TaperPower)
#define _TaperPower_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _SSSPower)
#define _SSSPower_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _SSSStrength)
#define _SSSStrength_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _OffsetDistance)
#define _OffsetDistance_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudCutoff)
#define _CloudCutoff_arr CloudsTest
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudSoftness)
#define _CloudSoftness_arr CloudsTest
		UNITY_INSTANCING_BUFFER_END(CloudsTest)

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float _midYValue_Instance = UNITY_ACCESS_INSTANCED_PROP(_midYValue_arr, _midYValue);
			float3 ase_worldPos = i.worldPos;
			float _cloudHeight_Instance = UNITY_ACCESS_INSTANCED_PROP(_cloudHeight_arr, _cloudHeight);
			float _TaperPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_TaperPower_arr, _TaperPower);
			float temp_output_104_0 = ( 1.0 - pow( saturate( ( abs( ( _midYValue_Instance - ase_worldPos.y ) ) / ( _cloudHeight_Instance * _VerticalFalloff ) ) ) , _TaperPower_Instance ) );
			float2 appendResult33 = (float2(ase_worldPos.x , ase_worldPos.z));
			float mulTime35 = _Time.y * _Cloudpanspeed;
			float2 temp_cast_0 = (mulTime35).xx;
			float4 _CircularMask_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_CircularMask_ST_arr, _CircularMask_ST);
			float2 uv_CircularMask = i.uv_texcoord * _CircularMask_ST_Instance.xy + _CircularMask_ST_Instance.zw;
			float temp_output_72_0 = ( ( tex2D( _CloudTexture, ( ( appendResult33 + mulTime35 ) * _NoiseTextureHigherSize ) ).r * tex2D( _CloudTexture, ( ( appendResult33 - temp_cast_0 ) * _DetailNoiseSize ) ).r ) * temp_output_104_0 * tex2D( _CircularMask, uv_CircularMask ).r );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult83 = dot( ase_worldViewDir , -ase_worldlightDir );
			float _SSSPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_SSSPower_arr, _SSSPower);
			float _SSSStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_SSSStrength_arr, _SSSStrength);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 _NoiseSplat_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_NoiseSplat_ST_arr, _NoiseSplat_ST);
			float2 uv_NoiseSplat = i.uv_texcoord * _NoiseSplat_ST_Instance.xy + _NoiseSplat_ST_Instance.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float _OffsetDistance_Instance = UNITY_ACCESS_INSTANCED_PROP(_OffsetDistance_arr, _OffsetDistance);
			o.Emission = ( ( temp_output_104_0 - ( temp_output_72_0 * temp_output_104_0 ) ) * ( pow( saturate( dotResult83 ) , _SSSPower_Instance ) * _SSSStrength_Instance * ase_lightColor ) * saturate( ( ( tex2D( _NoiseSplat, uv_NoiseSplat ).a - tex2D( _NoiseSplat, ( float3( i.uv_texcoord ,  0.0 ) + ( mul( ase_worldlightDir, ase_worldToTangent ) * _OffsetDistance_Instance ) ).xy ).a ) + 0.5 ) ) ).rgb;
			float2 temp_cast_4 = (mulTime35).xx;
			float _CloudCutoff_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudCutoff_arr, _CloudCutoff);
			float _CloudSoftness_Instance = UNITY_ACCESS_INSTANCED_PROP(_CloudSoftness_arr, _CloudSoftness);
			o.Alpha = pow( saturate( (0.0 + (temp_output_72_0 - _CloudCutoff_Instance) * (1.0 - 0.0) / (1.0 - _CloudCutoff_Instance)) ) , _CloudSoftness_Instance );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
0;517;1558;482;1331.088;643.2958;1.357862;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;32;-834.0181,-472.9445;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;54;-1001.03,87.71928;Inherit;False;InstancedProperty;_midYValue;midYValue;8;0;Create;True;0;0;False;0;0;7.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-809.2972,222.0522;Inherit;False;InstancedProperty;_cloudHeight;cloudHeight;9;0;Create;True;0;0;False;0;0;2.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-859.9775,327.5367;Inherit;False;Property;_VerticalFalloff;Vertical Falloff;12;0;Create;True;0;0;False;0;0.1762353;0.136;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;53;-803.0479,91.57988;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-555.532,-307.1171;Inherit;False;Property;_Cloudpanspeed;Cloud pan speed;0;0;Create;True;0;0;False;0;0.5;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;55;-608.5096,92.02168;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-564.171,-439.3363;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-572.6432,207.7287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;35;-378.7316,-307.7511;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;133;-144.8782,-223.0544;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;90;277.5445,408.5426;Inherit;False;1226.89;535.2894;Sub-Surface-Scattering;10;80;81;82;83;84;86;85;88;89;87;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;-284.0079,72.82498;Inherit;False;502.5545;273.0603;Old Taper method;3;68;61;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-169.5829,-311.9181;Inherit;False;Property;_NoiseTextureHigherSize;Noise Texture Higher Size;4;0;Create;True;0;0;False;0;0;0.34;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-139.276,-440.8185;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-436.5228,-172.9986;Inherit;False;Property;_DetailNoiseSize;Detail Noise Size;5;0;Create;True;0;0;False;0;0;0.1;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;56;-430.2732,91.90788;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-170.3574,122.8251;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-234.0079,229.8854;Inherit;False;InstancedProperty;_TaperPower;Taper Power;10;0;Create;True;0;0;False;0;0;2.78;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;81;327.5445,760.8313;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;9.050083,-154.1106;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;136;-244.4533,-715.5109;Inherit;True;Property;_CloudTexture;CloudTexture;14;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;3.257921,-441.0187;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;82;610.9073,741.8615;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;80;379.2865,594.4854;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;121;194.0787,-238.3949;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;-1;None;0071966237b5f0149a4395ab56a935c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;70;41.54658,178.8123;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;31;212.3385,-471.2709;Inherit;True;Property;_NoiseTexture;Noise Texture;3;0;Create;True;0;0;False;0;-1;None;0071966237b5f0149a4395ab56a935c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;104;355.74,185.774;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;592.0377,-819.6084;Inherit;True;Property;_CircularMask;CircularMask;11;0;Create;True;0;0;False;0;-1;None;c49ab7190c3872a4498395ef114cd70f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;561.8143,-295.7915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;83;759.1094,599.588;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;768.6512,-316.8597;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;951.6517,-122.2223;Inherit;False;InstancedProperty;_CloudCutoff;Cloud Cutoff;6;0;Create;True;0;0;False;0;0;0.316;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;84;889.5284,598.403;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;842.3534,689.6511;Inherit;False;InstancedProperty;_SSSPower;SSS Power;13;0;Create;True;0;0;False;0;0;1;1;56;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;683.2469,68.23553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;1143.843,740.037;Inherit;False;InstancedProperty;_SSSStrength;SSS Strength;15;0;Create;True;0;0;False;0;0;2.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;47;1319.704,-317.4118;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;87;1136.764,460.2735;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;85;1180.131,591.5767;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;1518.089,-479.0981;Inherit;False;InstancedProperty;_CloudSoftness;Cloud Softness;7;0;Create;True;0;0;False;0;0;1.15;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;1385.709,558.6374;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;140;1462.918,111.8157;Inherit;False;RimLight;1;;2;ec50d3fdea1b17849b6eee604bfc6118;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;49;1711.262,-324.2647;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;886.815,153.9103;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;1693.495,-112.6032;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;50;1886.74,-349.3329;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;137;172.9338,-620.3413;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2098.728,-554.1468;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Clouds Test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;53;0;54;0
WireConnection;53;1;32;2
WireConnection;55;0;53;0
WireConnection;33;0;32;1
WireConnection;33;1;32;3
WireConnection;73;0;58;0
WireConnection;73;1;76;0
WireConnection;35;0;36;0
WireConnection;133;0;33;0
WireConnection;133;1;35;0
WireConnection;37;0;33;0
WireConnection;37;1;35;0
WireConnection;56;0;55;0
WireConnection;56;1;73;0
WireConnection;68;0;56;0
WireConnection;122;0;133;0
WireConnection;122;1;123;0
WireConnection;43;0;37;0
WireConnection;43;1;44;0
WireConnection;82;0;81;0
WireConnection;121;0;136;0
WireConnection;121;1;122;0
WireConnection;70;0;68;0
WireConnection;70;1;61;0
WireConnection;31;0;136;0
WireConnection;31;1;43;0
WireConnection;104;0;70;0
WireConnection;132;0;31;1
WireConnection;132;1;121;1
WireConnection;83;0;80;0
WireConnection;83;1;82;0
WireConnection;72;0;132;0
WireConnection;72;1;104;0
WireConnection;72;2;65;1
WireConnection;84;0;83;0
WireConnection;63;0;72;0
WireConnection;63;1;104;0
WireConnection;47;0;72;0
WireConnection;47;1;48;0
WireConnection;85;0;84;0
WireConnection;85;1;86;0
WireConnection;88;0;85;0
WireConnection;88;1;89;0
WireConnection;88;2;87;0
WireConnection;49;0;47;0
WireConnection;64;0;104;0
WireConnection;64;1;63;0
WireConnection;94;0;64;0
WireConnection;94;1;88;0
WireConnection;94;2;140;0
WireConnection;50;0;49;0
WireConnection;50;1;51;0
WireConnection;0;2;94;0
WireConnection;0;9;50;0
ASEEND*/
//CHKSM=6440909FA89C580E9ADCE28E9A35BFD676A108EB
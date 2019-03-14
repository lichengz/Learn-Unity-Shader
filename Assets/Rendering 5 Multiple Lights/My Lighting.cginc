#pragma vertex vert
#pragma fragment frag

#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED


#include "UnityCG.cginc"
#include "UnityStandardBRDF.cginc"
#include "UnityStandardUtils.cginc"
#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

sampler2D _MainTex;
float4 _Tint;
float4 _SpecularTint;
float4 _MainTex_ST;
float _Smoothness;

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldPos = mul(unity_ObjectToWorld, v.uv);
    //o.normal = v.normal;
    //o.normal = mul(transpose((float3x3)unity_WorldToObject), v.normal);
    //o.normal = normalize(o.normal);
    o.normal = UnityObjectToWorldNormal(v.normal);
    return o;
}

UnityLight CreateLight (v2f i) {
	UnityLight light;
    #if defined(POINT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif
    //float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
	//float attenuation = 1 / (dot(lightVec, lightVec));
    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);

	light.color = _LightColor0.rgb * attenuation;;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

fixed4 frag (v2f i) : SV_Target
{
    i.normal = normalize(i.normal);
    //return float4(i.normal * 0.5 + 0.5, 1);
    //return dot(float3(0, 1, 0), i.normal);
    //return saturate(dot(float3(0, 1, 0), i.normal));
    
    float3 lightDir = _WorldSpaceLightPos0.xyz;
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    float3 reflectionDir = reflect(-lightDir, i.normal);

    float3 lightColor = _LightColor0.rgb;
    float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

    //albedo *= 1 - max(_SpecularTint.r, max(_SpecularTint.g, _SpecularTint.b));
    float oneMinusReflectivity;
	albedo = EnergyConservationBetweenDiffuseAndSpecular(
		albedo, _SpecularTint.rgb, oneMinusReflectivity
	);

	float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);

    float3 halfVector = normalize(lightDir + viewDir);
    float3 specular = _SpecularTint.rgb * lightColor * pow(
		DotClamped(halfVector, i.normal),
		_Smoothness * 100
	);
    //return float4(diffuse, 1);
    //return DotClamped(viewDir, reflectionDir);
    // return pow(
	// 	DotClamped(viewDir, reflectionDir),
	// 	_Smoothness * 100
	// );
    // return pow(
	// 	DotClamped(halfVector, i.normal),
	// 	_Smoothness * 100
	// );
    // return float4(diffuse + specular, 1);

    UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	return UNITY_BRDF_PBS(
		albedo, _SpecularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir,
		CreateLight(i), indirectLight
	);
}
#endif
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
        //transform.localEulerAngles = new Vector3(1, 1, 1);
        
	}
	
	// Update is called once per frame
	void Update () {
        transform.rotation = Quaternion.Euler(20, 0, 0);
	}
}

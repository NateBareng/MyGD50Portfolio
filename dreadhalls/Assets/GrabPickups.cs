using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GrabPickups : MonoBehaviour {

	public static int Pickup;
	private AudioSource pickupSoundSource;

	void Awake() {
		pickupSoundSource = DontDestroy.instance.GetComponents<AudioSource>()[1];
	}

	void OnControllerColliderHit(ControllerColliderHit hit) {
		if (hit.gameObject.tag == "Pickup") {
			pickupSoundSource.Play();
			Pickup++;
			SceneManager.LoadScene("Play");
		}
	}
}

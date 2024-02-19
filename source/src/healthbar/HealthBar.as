package healthbar {
import common.BaseControl;

import flash.geom.ColorTransform;

public class HealthBar extends BaseControl {

	private var m_healthBarView:HealthBarView = new HealthBarView();
	private var m_currentHealth:Number;
	private var m_isInfected:Boolean = false;

	public function HealthBar() {
		addChild(m_healthBarView);
	}

	public function SetHealth(health:Number):void {
		m_currentHealth = health;
		m_healthBarView.HealthBarText.text = String(Math.round(health));
		UpdateHealth()
	}

	public function SetInfected(isInfected:Boolean):void {
		m_isInfected = isInfected;

		if (isInfected) {
			m_healthBarView.HealthBarInner.gotoAndPlay(2);
		} else {
			m_healthBarView.HealthBarInner.gotoAndPlay(1);
		}

		UpdateHealthBarColour();
	}

	private function UpdateHealth():void {
		var m_maxHealth:Number = 100;
		m_healthBarView.HealthBarInner.scaleY = m_currentHealth / m_maxHealth;
		UpdateHealthBarColour();
	}

	private function UpdateHealthBarColour():void {
		if (m_isInfected) {
			var yellow:ColorTransform = new ColorTransform();
			yellow.color = 0xFFFF00;
			m_healthBarView.HealthBarInner.transform.colorTransform = yellow;
			return;
		}

		var m_maxHealth:Number = 100;
		var healthRatio:Number = m_currentHealth / m_maxHealth;
		var m_fullHealthGreen:uint = 0x00BA00;
		var m_lowHealthRed:uint = 0xFA0000;
		var red:uint = interpolate((m_lowHealthRed >> 16) & 0xFF, (m_fullHealthGreen >> 16) & 0xFF, healthRatio);
		var green:uint = interpolate((m_lowHealthRed >> 8) & 0xFF, (m_fullHealthGreen >> 8) & 0xFF, healthRatio);
		var blue:uint = interpolate(m_lowHealthRed & 0xFF, m_fullHealthGreen & 0xFF, healthRatio);
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.color = (red << 16) | (green << 8) | blue;
		m_healthBarView.HealthBarInner.transform.colorTransform = colorTransform;
	}

	private function interpolate(start:uint, end:uint, ratio:Number):uint {
		return start + (end - start) * ratio;
	}

	public function set Debug(health:Number):void {
		SetHealth(health);
	}

}
}
